//  PDFPreviewViewController.swift
//  Rewritten for Swift Package — no BaseVC dependency

import UIKit
import PDFKit

// MARK: - Models

public struct PDFModuleItem {
    public let moduleId: Int32
    public let courseId: Int32
    public let status: String
    public let location: String?

    public init(moduleId: Int32, courseId: Int32, status: String, location: String?) {
        self.moduleId = moduleId
        self.courseId = courseId
        self.status = status
        self.location = location
    }
}

public struct PDFCompletionPayload {
    public let moduleId: Int32
    public let courseId: Int32
    public let status: String   // "completed" | "inprogress"
    public let location: String // page index as string
}

// MARK: - ViewController

public final class PDFPreviewViewController: UIViewController {

    // MARK: Public config

    public var pdfURL: URL?
    public var courseID: Int32?
    public var moduleItem: PDFModuleItem?
    public var isCallCourseCompletion: Bool = false
    public var showAlertOnBackButtonPressed: Bool = true

    /// Called when the user exits and course completion should be reported.
    /// Caller is responsible for making the API call with the payload.
    public var onCompletion: ((PDFCompletionPayload) -> Void)?

    /// Called after dismiss is triggered (completion reported or skipped).
    public var onDismiss: (() -> Void)?

    // MARK: Private

    private var pdfDocument: PDFKit.PDFDocument?
    private var pdfView: PDFView!
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActivityIndicator()
        setupPDFView()
        setupNavigationBar()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pageChanged),
            name: .PDFViewPageChanged,
            object: nil
        )
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Orientation management is caller's responsibility in a package context.
        // Hook in via a subclass or set it in onDismiss/onCompletion if needed.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.color = .gray
        activityIndicator.autoresizingMask = [
            .flexibleTopMargin, .flexibleBottomMargin,
            .flexibleLeftMargin, .flexibleRightMargin
        ]
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func setupPDFView() {
        guard let pdfURL else {
            activityIndicator.stopAnimating()
            showError("No PDF URL provided.")
            return
        }

        pdfView = PDFView(frame: view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.displayMode = .singlePage
        pdfView.displaysPageBreaks = false
        pdfView.autoScales = true
        pdfView.usePageViewController(
            true,
            withViewOptions: [
                UIPageViewController.OptionsKey.spineLocation:
                    UIPageViewController.SpineLocation.min.rawValue
            ]
        )

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            guard let document = PDFKit.PDFDocument(url: pdfURL) else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showError("Failed to load PDF.")
                }
                return
            }

            self.pdfDocument = document

            DispatchQueue.main.async {
                self.pdfView.document = document
                self.view.insertSubview(self.pdfView, belowSubview: self.activityIndicator)
                self.activityIndicator.stopAnimating()
                self.restoreBookmark()
                self.updateTitle()
            }
        }
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .black

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Go to Page",
            style: .plain,
            target: self,
            action: #selector(goToPageButtonTapped)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }

    // MARK: - Bookmark / Page Restore

    private func restoreBookmark() {
        guard let moduleItem, moduleItem.status.lowercased() == "inprogress",
              let locationString = moduleItem.location,
              let savedIndex = Int(locationString), savedIndex > 0 else {
            goToPageIndex(0)
            return
        }

        let alert = UIAlertController(
            title: "Resume",
            message: "Would you like to continue from where you left off?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.goToPageIndex(savedIndex)
        })
        alert.addAction(UIAlertAction(title: "Start Over", style: .cancel) { [weak self] _ in
            self?.goToPageIndex(0)
        })
        present(alert, animated: true)
    }

    // MARK: - Navigation Actions

    @objc private func backButtonTapped() {
        guard showAlertOnBackButtonPressed else {
            triggerDismiss()
            return
        }

        let alert = UIAlertController(
            title: "Exit",
            message: "Are you sure you want to exit?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Exit", style: .default) { [weak self] _ in
            guard let self else { return }
            if self.isCallCourseCompletion {
                self.reportCompletionAndDismiss()
            } else {
                self.triggerDismiss()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func goToPageButtonTapped() {
        let alert = UIAlertController(
            title: "Go to Page",
            message: "Enter a page number",
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.placeholder = "Page number"
            tf.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Go", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text,
                  let page = Int(text) else { return }
            self?.goToPageNumber(page)
        })
        present(alert, animated: true)
    }

    // MARK: - Page Navigation

    /// Page number is 1-based (user-facing).
    private func goToPageNumber(_ pageNumber: Int) {
        guard let pdfDocument,
              pageNumber > 0,
              pageNumber <= pdfDocument.pageCount,
              let page = pdfDocument.page(at: pageNumber - 1) else { return }
        UIView.animate(withDuration: 0.3) { self.pdfView.go(to: page) }
    }

    /// Page index is 0-based (internal).
    private func goToPageIndex(_ index: Int) {
        guard let pdfDocument,
              index >= 0,
              index < pdfDocument.pageCount,
              let page = pdfDocument.page(at: index) else { return }
        pdfView.go(to: page)
    }

    @objc private func pageChanged() {
        updateTitle()
    }

    private func updateTitle() {
        guard let currentPage = pdfView?.currentPage,
              let document = pdfView?.document else { return }
        let current = document.index(for: currentPage) + 1
        navigationItem.title = "\(current) of \(document.pageCount)"
    }

    // MARK: - Completion

    private func reportCompletionAndDismiss() {
        let payload = buildCompletionPayload()
        onCompletion?(payload)
        triggerDismiss()
    }

    private func buildCompletionPayload() -> PDFCompletionPayload {
        let currentIndex = getCurrentPageIndex() ?? 0
        let totalPages = pdfDocument?.pageCount ?? 1
        let status = currentIndex >= (totalPages - 1) ? "completed" : "inprogress"
        return PDFCompletionPayload(
            moduleId: moduleItem?.moduleId ?? 0,
            courseId: courseID ?? 0,
            status: status,
            location: "\(currentIndex)"
        )
    }

    private func triggerDismiss() {
        self.onDismiss?()
    }

    // MARK: - Helpers

    private func getCurrentPageIndex() -> Int? {
        guard let currentPage = pdfView?.currentPage,
              let document = pdfView?.document else { return nil }
        return document.index(for: currentPage)
    }

    private func showError(_ message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
}

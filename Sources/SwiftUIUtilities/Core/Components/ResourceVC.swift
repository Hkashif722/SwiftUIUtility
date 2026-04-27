//
//  ResourceVC.swift
//

import UIKit
@preconcurrency import WebKit

public class ResourceVC: UIViewController {

    // MARK: - Public Configuration

    public var filePath: String = ""
    public var isOnline: Bool = false
    public var isScormDoc: Bool = false
    public var strScormDocPath: String = ""
    public var fromAssignment: Bool = false
    public var strTitle: String = ""

    // MARK: - Private UI

    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Init

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupWebView()
        title = strTitle
        launchResource()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationItem.setLeftBarButton(nil, animated: false)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }

    // MARK: - Setup
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.bounces = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.stopAnimating()
        webView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
    }

    // MARK: - Resource Loading

    private func launchResource() {
        if isScormDoc, !strScormDocPath.isEmpty {
            guard let url = URL(string: strScormDocPath) else { return }
            webView.load(URLRequest(url: url))

        } else if isOnline, let completePath = URL(string: filePath) {
            loadOnlineResource(completePath)

        } else {
            loadLocalResource()
        }
    }

    private func loadOnlineResource(_ completePath: URL) {
        let fileExtension = completePath.pathExtension.lowercased()
        let html: String

        switch fileExtension {
        case "jpg", "jpeg", "png", "gif", "webp", "bmp", "svg":
            html = createImageHTML(completePath.absoluteString)
        case "mp4", "mov", "avi", "mkv", "webm", "m4v":
            html = createVideoHTML(completePath.absoluteString)
        case "mp3", "wav", "aac", "m4a", "flac":
            html = createAudioHTML(completePath.absoluteString)
        case "pdf":
            html = createPDFHTML(completePath.absoluteString)
        default:
            if let documentURL = ResourceUtils.getOfficeURLIfExists(completePath.absoluteString) {
                webView.load(URLRequest(url: documentURL))
            }
            return
        }

        webView.loadHTMLString(html, baseURL: nil)
    }

    private func loadLocalResource() {
        let courseFile = filePath.replace(" ", replacement: "%20")
        var finalUrl = courseFile

        if !courseFile.isValidURL {
            finalUrl = EncryptDecryptUtility.shared.newDecryptString(responseStr: courseFile)
        }

        if fromAssignment {
            guard let fileUrl = ResourceUtils.createENCURL(from: finalUrl) else { return }
            let completePath = ResourceUtils.fileUrl(fileName: fileUrl.lastPathComponent)
            webView.load(URLRequest(url: completePath))
        } else {
            guard let fileUrl = URL(string: finalUrl) else {
                print("ResourceVC: Invalid URL — \(finalUrl)")
                return
            }
            guard FileManager.default.fileExists(atPath: fileUrl.path) else {
                print("ResourceVC: File not found at \(fileUrl.path)")
                return
            }
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            webView.loadFileURL(fileUrl, allowingReadAccessTo: documentsDirectory)
        }
    }

    public func loadURLDirectly(_ url: URL) {
        webView.load(URLRequest(url: url))
    }

    // MARK: - Actions

    @objc private func didSelectCancelBtn() {
        let alert = UIAlertController(
            title: "",
            message: "ExitMessageTxt".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes_Title".localized, style: .default) { [weak self] _ in
            guard let self else { return }
            self.webView.removeFromSuperview()
            self.webView = nil
            self.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "No_Title".localized, style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension ResourceVC: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url, url.scheme != nil else {
            decisionHandler(.cancel)
            return
        }
        if url.scheme == "mailto" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - HTML Builders

extension ResourceVC {

    private func createImageHTML(_ imagePath: String) -> String {
        """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
            <style>
                body { margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #f0f0f0; }
                img { max-width: 100%; max-height: 100vh; height: auto; display: block; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
            </style>
        </head>
        <body><img src="\(imagePath)" alt="Image" /></body>
        </html>
        """
    }

    private func createVideoHTML(_ videoPath: String) -> String {
        """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
            <style>
                body { margin: 0; display: flex; justify-content: center; align-items: center; min-height: 100vh; background: #000; }
                video { max-width: 100%; max-height: 100vh; height: auto; display: block; border-radius: 8px; }
            </style>
        </head>
        <body>
            <video controls preload="metadata" playsinline>
                <source src="\(videoPath)" type="video/mp4">
                <source src="\(videoPath)" type="video/quicktime">
                <source src="\(videoPath)" type="video/webm">
            </video>
        </body>
        </html>
        """
    }

    private func createAudioHTML(_ audioPath: String) -> String {
        let fileName = URL(fileURLWithPath: audioPath).lastPathComponent
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; display: flex; flex-direction: column; justify-content: center; align-items: center; min-height: 100vh; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); font-family: -apple-system, sans-serif; }
                .audio-container { background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); border-radius: 16px; padding: 30px; text-align: center; }
                .audio-icon { font-size: 48px; margin-bottom: 20px; }
                audio { width: 300px; max-width: 90vw; }
                .file-name { color: white; margin-top: 15px; font-size: 14px; opacity: 0.8; }
            </style>
        </head>
        <body>
            <div class="audio-container">
                <div class="audio-icon">🎵</div>
                <audio controls preload="metadata">
                    <source src="\(audioPath)" type="audio/mpeg">
                    <source src="\(audioPath)" type="audio/wav">
                    <source src="\(audioPath)" type="audio/aac">
                </audio>
            </div>
        </body>
        </html>
        """
    }

    private func createPDFHTML(_ pdfPath: String) -> String {
        """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; height: 100vh; background: #f0f0f0; }
                embed { width: 100%; height: 100%; border: none; }
            </style>
        </head>
        <body><embed src="\(pdfPath)" type="application/pdf" /></body>
        </html>
        """
    }
}

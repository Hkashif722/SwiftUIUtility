//
//  Picker.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 04/03/26.
//


import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

// MARK: - DocumentPicker

public struct DocumentPicker: UIViewControllerRepresentable {
    public var onDocumentPicked: (URL?) -> Void

    public init(onDocumentPicked: @escaping (URL?) -> Void) {
        self.onDocumentPicked = onDocumentPicked
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
        UINavigationBar.appearance().shadowImage = nil
        UINavigationBar.appearance().tintColor = .systemBlue

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let originalURL = urls.first else { parent.onDocumentPicked(nil); return }
            parent.onDocumentPicked(copyToTemporaryDirectory(originalURL))
        }

        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onDocumentPicked(nil)
        }

        private func copyToTemporaryDirectory(_ originalURL: URL) -> URL? {
            let didStartAccessing = originalURL.startAccessingSecurityScopedResource()
            defer { if didStartAccessing { originalURL.stopAccessingSecurityScopedResource() } }

            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent(originalURL.lastPathComponent)

            let fm = FileManager.default
            if fm.fileExists(atPath: destination.path) {
                do { try fm.removeItem(at: destination) }
                catch { print("DocumentPicker: remove error \(error)"); return nil }
            }
            do { try fm.copyItem(at: originalURL, to: destination); return destination }
            catch { print("DocumentPicker: copy error \(error)"); return nil }
        }
    }
}

// MARK: - PhotoPicker

public struct PhotoPicker: UIViewControllerRepresentable {
    public var onPhotoPicked: (URL?) -> Void

    public init(onPhotoPicked: @escaping (URL?) -> Void) {
        self.onPhotoPicked = onPhotoPicked
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first,
                  result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                parent.onPhotoPicked(nil)
                picker.dismiss(animated: true)
                return
            }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                guard let self, let image = object as? UIImage, error == nil else {
                    DispatchQueue.main.async {
                        self?.parent.onPhotoPicked(nil)
                        picker.dismiss(animated: true)
                    }
                    return
                }
                let url = self.saveImageToTemporaryDirectory(image: image)
                DispatchQueue.main.async {
                    self.parent.onPhotoPicked(url)
                    picker.dismiss(animated: true)
                }
            }
        }

        private func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            do { try data.write(to: fileURL); return fileURL }
            catch { print("PhotoPicker: save error \(error)"); return nil }
        }
    }
}

// MARK: - MultiPhotoPicker

public struct MultiPhotoPicker: UIViewControllerRepresentable {
    public var onPhotosPicked: ([URL]) -> Void

    public init(onPhotosPicked: @escaping ([URL]) -> Void) {
        self.onPhotosPicked = onPhotosPicked
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiPhotoPicker
        init(_ parent: MultiPhotoPicker) { self.parent = parent }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else { parent.onPhotosPicked([]); return }

            let group = DispatchGroup()
            var fileURLs = [URL]()

            for result in results where result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    defer { group.leave() }
                    guard let self, let image = object as? UIImage, error == nil else { return }
                    if let url = self.saveImageToTemporaryDirectory(image: image) {
                        fileURLs.append(url)
                    }
                }
            }

            group.notify(queue: .main) { self.parent.onPhotosPicked(fileURLs) }
        }

        private func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
            let fileURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".jpg")
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            do { try data.write(to: fileURL); return fileURL }
            catch { print("MultiPhotoPicker: save error \(error)"); return nil }
        }
    }
}

// MARK: - VideoPicker

public struct VideoPicker: UIViewControllerRepresentable {
    public var onVideoPicked: (URL?) -> Void

    public init(onVideoPicked: @escaping (URL?) -> Void) {
        self.onVideoPicked = onVideoPicked
    }

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public func makeUIViewController(context: Context) -> UIViewController {
        let container = UIViewController()
        let coord = context.coordinator

        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .videos
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = coord

        container.addChild(picker)
        container.view.addSubview(picker.view)
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.view.topAnchor.constraint(equalTo: container.view.topAnchor),
            picker.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            picker.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
        ])
        picker.didMove(toParent: container)

        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        container.view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: container.view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
        ])

        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(label)

        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = UIColor(white: 1, alpha: 0.3)
        bar.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(bar)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -10),
            bar.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12),
            bar.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            bar.widthAnchor.constraint(equalToConstant: 200),
        ])

        coord.container    = container
        coord.overlayView  = overlay
        coord.statusLabel  = label
        coord.progressView = bar

        return container
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    @MainActor
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        enum Phase { case loading, compressing }

        private let parent: VideoPicker
        weak var container: UIViewController?
        weak var overlayView: UIView?
        weak var statusLabel: UILabel?
        weak var progressView: UIProgressView?

        private var fileProgress: Progress?
        private var exportSession: AVAssetExportSession?
        private var timer: Timer?
        private var phase: Phase = .loading

        init(_ parent: VideoPicker) { self.parent = parent }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first,
                  result.itemProvider.hasItemConformingToTypeIdentifier("public.movie") else {
                finish(with: nil); return
            }

            phase = .loading
            showOverlay(text: "Loading…", progress: 0)

            fileProgress = result.itemProvider.loadFileRepresentation(
                forTypeIdentifier: "public.movie"
            ) { [weak self] url, _ in
                guard let self else { return }
                guard let sourceURL = url else {
                    Task { @MainActor [weak self] in self?.finish(with: nil) }
                    return
                }

                DispatchQueue.main.sync {
                    self.fileProgress?.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
                    self.fileProgress = nil
                    self.phase = .compressing
                    self.showOverlay(text: "Compressing…", progress: 0)
                }

                let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
                let movURL = tmp.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
                do { try FileManager.default.copyItem(at: sourceURL, to: movURL) }
                catch {
                    Task { @MainActor [weak self] in self?.finish(with: nil) }
                    return
                }

                guard let session = AVAssetExportSession(
                    asset: AVAsset(url: movURL),
                    presetName: AVAssetExportPresetMediumQuality
                ) else {
                    Task { @MainActor [weak self] in self?.finish(with: nil) }
                    return
                }

                Task { @MainActor [weak self] in self?.exportSession = session }

                session.outputURL = tmp
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")
                session.outputFileType = .mp4
                session.shouldOptimizeForNetworkUse = true

                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                        Task { @MainActor [weak self] in
                            guard let self, self.phase == .compressing,
                                  let ses = self.exportSession else { return }
                            self.updateProgress(ses.progress, message: "Compressing…")
                        }
                    }
                }

                session.exportAsynchronously { [weak self, weak session] in
                    guard let self, let session else { return }
                    let status    = session.status
                    let outputURL = session.outputURL
                    DispatchQueue.main.async {
                        self.timer?.invalidate()
                        self.finish(with: status == .completed ? outputURL : nil)
                    }
                }
            }

            if let fp = fileProgress {
                fp.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)
            }
        }

        public override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard keyPath == #keyPath(Progress.fractionCompleted),
                  let prog = object as? Progress,
                  phase == .loading else { return }
            updateProgress(Float(prog.fractionCompleted), message: "Loading…")
        }

        private func showOverlay(text: String, progress: Float) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                overlayView?.isHidden = false
                statusLabel?.text = text
                progressView?.setProgress(progress, animated: true)
                if let overlay = overlayView { container?.view.bringSubviewToFront(overlay) }
            }
        }

        private func updateProgress(_ fraction: Float, message: String) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                statusLabel?.text = "\(message) \(Int(fraction * 100))%"
                progressView?.setProgress(fraction, animated: true)
            }
        }

        private func finish(with url: URL?) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                overlayView?.isHidden = true
                parent.onVideoPicked(url)
                container?.dismiss(animated: true)
            }
        }
    }
}

// MARK: - FileDownloadPicker



public struct FileDownloadPicker: UIViewControllerRepresentable {
    public let model: NavigationViewModel.FileDownloadPickerNavModel

    public init(model: NavigationViewModel.FileDownloadPickerNavModel) {
        self.model = model
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(onCompletion: model.onCompletion)
    }

    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempURL = model.temporaryFileURL
        guard FileManager.default.fileExists(atPath: tempURL.path) else {
            fatalError("FileDownloadPicker: temporary file not found at \(tempURL)")
        }
        let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        picker.delegate = context.coordinator
        picker.shouldShowFileExtensions = true
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        public let onCompletion: (URL?) -> Void
        public init(onCompletion: @escaping (URL?) -> Void) { self.onCompletion = onCompletion }

        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onCompletion(urls.first)
        }
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCompletion(nil)
        }
    }
}

// MARK: - Debug Preview

#if DEBUG
struct ResourcePickerView: View {
    @State private var isDocumentPickerPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var isVideoPickerPresented = false
    @State private var selectedDocumentURL: URL?
    @State private var selectedImageURL: URL?
    @State private var selectedVideoURL: URL?

    var body: some View {
        VStack(spacing: 20) {
            Button("Pick a Document") { isDocumentPickerPresented = true }
                .sheet(isPresented: $isDocumentPickerPresented) {
                    DocumentPicker { selectedDocumentURL = $0 }
                }

            Button("Pick a Photo") { isPhotoPickerPresented = true }
                .sheet(isPresented: $isPhotoPickerPresented) {
                    PhotoPicker { selectedImageURL = $0 }
                }

            Button("Pick a Video") { isVideoPickerPresented = true }
                .sheet(isPresented: $isVideoPickerPresented) {
                    VideoPicker { selectedVideoURL = $0 }
                }

            if let url = selectedDocumentURL {
                Text("Document: \(url.lastPathComponent)")
            }

            if let url = selectedImageURL,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFit().frame(height: 200)
            }

            if let url = selectedVideoURL {
                Text("Video: \(url.lastPathComponent)")
            }
        }
        .padding()
    }
}

#Preview { ResourcePickerView() }
#endif

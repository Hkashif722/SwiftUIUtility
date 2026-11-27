//
//  CachedAsyncImage.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//


import SwiftUI
import Nuke

public struct CachedAsyncImage: View {
    
    
    let url: URL?
    var placeHolderImage: String
    public var bundle: Bundle
    var resizedImageProcessors: [ImageProcessing] = [] // Optional image processors
   
    
    // This one uses the module bundle automatically
    public init(url: URL?, placeHolderImage: String = "course_default", resizedImageProcessors: [ImageProcessing] = [] ) {
        self.init(url: url, placeHolderImage: placeHolderImage, bundle: .module, resizedImageProcessors: resizedImageProcessors)
    }

    // This one allows a custom bundle
    public init(url: URL?, placeHolderImage: String = "course_default", bundle: Bundle, resizedImageProcessors: [ImageProcessing] = []) {
        self.url = url
        self.placeHolderImage = placeHolderImage
        self.bundle = bundle
        self.resizedImageProcessors = resizedImageProcessors
    }
    
    public var randomThumbnail: String? {
        let thumbnails = (1...150).map {
            "\(APIConst.ContentPath)/assets/img/Thumbnail_vectors/img_thumb\($0).jpg"
        }
        return thumbnails.randomElement()
    }
    
    @StateObject private var viewModel = ImageLoaderViewModel()


    public var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
            case .failure, .noURL:
                placeholderView
            }
        }
        .onChange(of: url) { newURL in
            if let url = newURL {
                Task {
                    await viewModel.loadImage(url: url, processors: resizedImageProcessors)
                }
               
            } else {
                viewModel.state = .noURL
            }
        }
        .onAppear {
            if let safeURL = url {
                let finalPath = (safeURL.absoluteString == "\(APIConst.ContentPath)/" && placeHolderImage == "course_default") ? URL(string:self.randomThumbnail ?? "") : safeURL
                Task {
                    await viewModel.loadImage(url: finalPath, processors: resizedImageProcessors)
                }
            } else {
                viewModel.state = .noURL
            }
        }
    }

    @ViewBuilder
    private var placeholderView: some View {
        if placeHolderImage.hasPrefix("http"), let url = URL(string: placeHolderImage) {
            PlaceholderURLImageView(url: url)
        } else if let uiImage = UIImage(named: placeHolderImage) {
            Image(uiImage: uiImage).resizable()
        } else {
            Color.gray.opacity(0.15)
        }
    }
}

private struct PlaceholderURLImageView: View {
    let url: URL
    @StateObject private var loader = ImageLoaderViewModel()

    var body: some View {
        Group {
            if case .success(let img) = loader.state {
                Image(uiImage: img).resizable()
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .onAppear {
            Task { await loader.loadImage(url: url, processors: []) }
        }
    }
}

@MainActor
class ImageLoaderViewModel: ObservableObject {
    @Published var state: ImageLoadingState = .loading

    func loadImage(url: URL?, processors: [ImageProcessing]) async {
        guard let url = url else {
            Task {  @MainActor [weak self] in
                self?.state = .noURL
            }
            
            return
        }
//        state = .loading

        let request = ImageRequest(url: url, processors: processors)
        do {
            let imageResponse = try await ImagePipeline.shared.image(for: request)
            Task {  @MainActor [weak self] in
                self?.state = .success(imageResponse)
            }
        } catch {
            Task {  @MainActor [weak self] in
                self?.state = .failure
            }
        }
    }
}

enum ImageLoadingState {
    case loading
    case success(UIImage)
    case failure
    case noURL
}

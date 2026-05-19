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





//import SwiftUI
//import Combine
//
//// ImageCache class with shared instance and NSCache for caching UIImage
//class SwiftUIImageCache {
//    
//    static let defaultImgUrl = URL(string:  "https://content.gogetempowered.com//assets/img/Thumbnail_vectors/img_thumb63.jpg")!
//    static let shared = SwiftUIImageCache()
//    private init() {}
//    
//    private let cache = NSCache<NSURL, UIImage>()
//    
//    func getImage(for url: URL) -> UIImage? {
//        return cache.object(forKey: url as NSURL)
//    }
//    
//    func saveImage(_ image: UIImage, for url: URL) {
//        cache.setObject(image, forKey: url as NSURL)
//    }
//}
//
//struct CachedAsyncImage: View {
//    let url: URL?
//    var placeHolderImage: String = "course_default"
//    @State private var image: UIImage? = nil
//    @State private var isLoading: Bool = false
//    
//    var body: some View {
//        
//        Group {
//            
//            switch image {
//            
//            case .some(let image):
//                Image(uiImage: image)
//                    .resizable()
//            default:
//                HStack {
//                    ProgressView()
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//        .onAppear {
//            loadImage(url)
//        }
//    }
//    
//    private func loadImage(_ url: URL?, retryCount: Int = 0, maxRetries: Int = 2) {
//        
//        guard let url = url else {
//            print("Invalid or nil URL")
//            if retryCount < maxRetries, let placeholderURL = URL(string: placeHolderImage), !placeHolderImage.isBlank {
//                loadImage(placeholderURL, retryCount: retryCount + 1, maxRetries: maxRetries)
//            } else {
//                self.image = UIImage(named: "course_default")
//            }
//            return
//        }
//        
//        // Check cache first
//        if let cachedImage = SwiftUIImageCache.shared.getImage(for: url) {
//            self.image = cachedImage
//            return
//        }
//        
//        // Start loading the image
//        DispatchQueue.main.async {
//            isLoading = true
//        }
//        Task {
//            do {
//                let (data, _) = try await URLSession.shared.data(from: url)
//                if let downloadedImage = UIImage(data: data) {
//                    // Save to cache
//                    SwiftUIImageCache.shared.saveImage(downloadedImage, for: url)
//                    // Update the state on the main thread
//                    await MainActor.run {
//                        self.image = downloadedImage
//                    }
//                } else {
//                    if !placeHolderImage.isBlank , retryCount < maxRetries, let placeholderURL = URL(string: placeHolderImage), !placeHolderImage.isBlank {
//                        loadImage(placeholderURL, retryCount: retryCount + 1, maxRetries: maxRetries)
//                    } else {
//                        self.image = UIImage(named: "course_default")
//                    }
//                }
//            } catch {
//                print("Error loading image: \(error.localizedDescription)")
//                if !placeHolderImage.isBlank, retryCount < maxRetries, let placeholderURL = URL(string: placeHolderImage), !placeHolderImage.isBlank {
//                    loadImage(placeholderURL, retryCount: retryCount + 1, maxRetries: maxRetries)
//                } else {
//                    self.image = UIImage(named: "course_default")
//                }
//            }
//            
//            DispatchQueue.main.async {
//                isLoading = false
//            }
//        }
//    }
//    
//}

//
//  AsyncImageWithFallback.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 30/01/26.
//

import SwiftUI

/// A reusable view that loads images from URLs with fallback support
public struct AsyncImageWithFallback: View {
    let urlString: String?
    let defaultImageName: String
    let contentMode: ContentMode
    let bundle: Bundle?

    private var url: URL? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private var defaultImage: Image {
        Image(defaultImageName, bundle: bundle)
    }

    /// - Parameters:
    ///   - bundle: Pass `.module` when used inside a Swift Package (default). Pass `nil` for the main app bundle.
    public init(
        urlString: String?,
        defaultImageName: String,
        contentMode: ContentMode = .fit,
        bundle: Bundle? = .module
    ) {
        self.urlString = urlString
        self.defaultImageName = defaultImageName
        self.contentMode = contentMode
        self.bundle = bundle
    }

    public var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
    }

    private var fallbackView: some View {
        defaultImage
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

/// A reusable view that loads images from URLs with fallback support and clipped corner radius
public struct AsyncImageWithFallbackClipped: View {
    let urlString: String?
    let defaultImageName: String
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let bundle: Bundle?

    private var url: URL? {
        guard let urlString = urlString, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }

    private var defaultImage: Image {
        Image(defaultImageName, bundle: bundle)
    }

    /// - Parameters:
    ///   - bundle: Pass `.module` when used inside a Swift Package (default). Pass `nil` for the main app bundle.
    public init(
        urlString: String?,
        defaultImageName: String,
        contentMode: ContentMode = .fit,
        cornerRadius: CGFloat = 0,
        bundle: Bundle? = .module
    ) {
        self.urlString = urlString
        self.defaultImageName = defaultImageName
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.bundle = bundle
    }

    public var body: some View {
        Group {
            if let url = url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var fallbackView: some View {
        defaultImage
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

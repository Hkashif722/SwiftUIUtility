//
//  AsyncImageWithFallback.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 30/01/26.
//


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
    let cornerRadius: CGFloat // 👈 add this

    public init(
        urlString: String?,
        defaultImageName: String,
        contentMode: ContentMode = .fit,
        cornerRadius: CGFloat = 0 // 👈 default 0 so existing usages won't break
    ) {
        self.urlString = urlString
        self.defaultImageName = defaultImageName
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
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
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius)) // ✅ applied on Group itself
    }

    private var fallbackView: some View {
        defaultImage
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

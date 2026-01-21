//
//  UIKitBridge.swift
//  SwiftUIUtilities
//
//  Created by Package on 13/01/26.
//

import SwiftUI
import WebKit

/// Bridge for UIKit components
public struct UIKitBridgeVCRepresentable {
    
    /// GIF WebView for displaying animated GIFs
    public struct GIFWebView: UIViewRepresentable {
        let gifName: String
        
        public init(gifName: String) {
            self.gifName = gifName
        }
        
        public func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.scrollView.isScrollEnabled = false
            webView.backgroundColor = .clear
            webView.isOpaque = false
            return webView
        }
        
        public func updateUIView(_ webView: WKWebView, context: Context) {
            guard let url = Bundle.swiftUIUtilitiesModule.url(forResource: gifName, withExtension: "gif"),
                  let data = try? Data(contentsOf: url) else {
                return
            }
            
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: url.deletingLastPathComponent()
            )
        }
    }
}

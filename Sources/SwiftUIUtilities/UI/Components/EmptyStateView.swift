//
//  EmptyStateView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 13/01/26.
//

import SwiftUI

public struct EmptyStateView: View {
    public let icon: Image               // Required icon (can be any view)
    public let gifName: String?
    public let title: String?            // Required title for the empty state
    public let label: String?            // Optional label (default is nil)
    public let actionButton: AnyView?    // Optional action button (can be nil)
    
    public init(icon: Image, gifName: String?, title: String? = nil, label: String? = nil, actionButton: AnyView? = nil) {
        self.icon = icon
        self.title = title
        self.gifName = gifName
        self.label = label
        self.actionButton = actionButton
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            iconOrGifView
            
            infoView
            
            if let actionButton = actionButton {
                actionButton
                    .padding(.top, 8)
            }
        }
        .padding()
        .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    private var iconOrGifView: some View {
        if let gifName = gifName {
            UIKitBridgeVCRepresentable.GIFWebView(gifName: gifName)
                .frame(height: 300)
        } else {
            icon
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
    
    private var infoView: some View {
        VStack(spacing: 8) {
            if let title = title {
                Text(title)  // Display the title
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorUtility.primaryColor)
            }
            if let label = label {
                Text(label)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        
    }
}

extension EmptyStateView {
    public init(emptyState: EmptyStateData) {
        let content = emptyState.content
        self.init(
            icon: content.icon,
            gifName: content.gifName,
            title: content.title,
            label: content.label,
            actionButton: content.actionButton
        )
    }
}


public struct SimpleEmptyStateView: View {
    public var textMsg: String = "Start typing to get search results."
    
    public init(textMsg: String = "Start typing to get search results.") {
        self.textMsg = textMsg
    }
    
    public var body: some View {
        Text(textMsg)
            .foregroundColor(.gray)
            .font(.subheadline)
            .matchToParentContainer()
    }
}

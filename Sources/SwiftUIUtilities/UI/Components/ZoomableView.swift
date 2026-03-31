//
//  ZoomableView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//


//
//  ZoomableView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 20/10/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//

import SwiftUI

/// A view that enables zooming and panning of its content while maintaining aspect ratio and zoom limits.
public struct ZoomableView<Content: View>: View {
    
    // MARK: - Properties
    
    /// The content to display inside the zoomable view.
    private let content: Content
    
    /// The current scale factor for zooming.
    @State private var scale: CGFloat
    
    /// The current offset for panning.
    @State private var offset: CGSize = .zero
    
    /// The last known offset, used to calculate incremental panning.
    @State private var lastOffset: CGSize = .zero
    
    /// Base zoom scale for more controlled zoom sensitivity.
    private var zoomBase: CGFloat = 1.0
    
    /// Minimum zoom step to prevent over-sensitive scaling.
    private let zoomStep: CGFloat = 0.2
    
    // MARK: - Constants
    
    /// The minimum scale allowed for zooming.
    private let minScale: CGFloat = 1.0
    
    /// The maximum scale allowed for zooming.
    private let maxScale: CGFloat = 5.0
    
    // MARK: - Initialization
    
    /// Creates a `ZoomableView` with the specified content and an optional initial scale factor.
    /// - Parameters:
    ///   - initialScale: The initial scale factor. Default is 1.0 (no zoom).
    ///   - content: A view builder that provides the content to be zoomed and panned.
    public init(initialScale: CGFloat = 1.0, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._scale = State(initialValue: initialScale) // Set initial scale
        self.zoomBase = initialScale
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            content
                .scaleEffect(scale)
                .offset(x: validOffset(width: geometry.size.width, contentWidth: geometry.size.width * scale, offset: offset.width),
                        y: validOffset(height: geometry.size.height, contentHeight: geometry.size.height * scale, offset: offset.height))
                .gesture(
                    SimultaneousGesture(
                        magnificationGesture(),
                        dragGesture(geometrySize: geometry.size)
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .clipped()
                .animation(.easeInOut, value: scale)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Private Helpers
    
    /// Creates a magnification gesture to handle zooming with reduced sensitivity.
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // Apply incremental zoom based on gesture changes
                let delta = (value - 1) * zoomStep
                // Update scale with dampened zoom increment
                scale = min(max(minScale, scale + delta), maxScale)
            }
            .onEnded { _ in
                // Ensure the final scale remains within valid bounds
                scale = min(max(minScale, scale), maxScale)
            }
    }
    
    /// Creates a drag gesture to handle panning.
    private func dragGesture(geometrySize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Update the offset, but clamp it to the valid bounds to avoid dragging too far off-screen
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                // Save the last offset when the gesture ends
                lastOffset = offset
            }
    }
    
    /// Calculates the valid offset to keep the content within visible bounds.
    private func validOffset(width: CGFloat, contentWidth: CGFloat, offset: CGFloat) -> CGFloat {
        let maxOffset = (contentWidth - width) / 2
        let validOffset = min(max(-maxOffset, offset), maxOffset)
        return contentWidth > width ? validOffset : 0
    }
    
    /// Calculates the valid offset to keep the content within visible bounds.
    private func validOffset(height: CGFloat, contentHeight: CGFloat, offset: CGFloat) -> CGFloat {
        let maxOffset = (contentHeight - height) / 2
        let validOffset = min(max(-maxOffset, offset), maxOffset)
        return contentHeight > height ? validOffset : 0
    }
}

#Preview {
    ZoomableView {
        Image("img1")
            .resizable()
            .scaledToFit()
    }
}

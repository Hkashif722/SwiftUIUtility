//
//  File.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 04/03/26.
//

import SwiftUI
import SwiftfulLoadingIndicators

// MARK: - Loading Overlay View
public extension View {
    
    /// - Parameter bottomContent: Optional view pinned to the bottom of the loading card.
    func loadingOverlayViewPkg<BottomContent: View>(
        state: LoadingState?,
        @ViewBuilder bottomContent: () -> BottomContent = { EmptyView() }
    ) -> some View {
        ZStack {
            if let state = state {
                self
                    .disabled(state.isLoading)
                    .blur(radius: state.isLoading ? 3 : 0)
                
                if state.isLoading {
                    loadingOverlay(for: state, bottomContent: bottomContent)
                }
            } else {
                self
            }
        }
    }
    
    private func loadingOverlay<BottomContent: View>(
        for state: LoadingState,
        @ViewBuilder bottomContent: () -> BottomContent
    ) -> some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
                loadingContent(for: state, bottomContent: bottomContent)
            }
    }
    
    private func loadingContent<BottomContent: View>(
        for state: LoadingState,
        @ViewBuilder bottomContent: () -> BottomContent
    ) -> some View {
        VStack(spacing: 16) {
            progressView(for: state)
            titleText(state.title, state: state)
            messageText(state.message, state: state)
            
            // Only renders when a non-EmptyView is provided
            bottomContent()
        }
        .padding(20)
        .background(Color(hex: "#F5F7F8"))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    private func progressView(for state: LoadingState) -> some View {
        switch state {
        case .progressLoading(let progress, _, _, let indicator):
            if let customIndicator = indicator {
                LoadingIndicator(animation: customIndicator)
                    .frame(width: 200)
            } else {
                SwiftUIUtility.CircularProgressView(progress: progress)
                    .frame(width: 200)
            }
            
        case .loading(_, _, let indicator):
            if let customIndicator = indicator {
                LoadingIndicator(animation: customIndicator)
                    .frame(width: 60, height: 60)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding(5)
            }
            
        case .none, .loaded:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func titleText(_ title: String, state: LoadingState) -> some View {
        if !title.isEmpty, case .loading(_, _, indicator: nil) = state {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.gray)
                .multilineTextAlignment(.center)
        }
    }
    
    @ViewBuilder
    private func messageText(_ message: String, state: LoadingState) -> some View {
        if case .loading(_, _, indicator: nil) = state {
            Text(message)
                .font(.headline)
                .foregroundStyle(Color(.lightGray))
                .multilineTextAlignment(.center)
        }
    }
    
    func rippleEffectPkg(isAnimated: Bool, color: Color = .blue, fade: CGFloat = 0.3,duration: Double = 1.0, maxScale: CGFloat = 5.0) -> some View {
        self.modifier(
            AnimationEffect.RippleEffectModifier(
                animate: isAnimated,
                color: color,
                fade: fade,
                duration: duration,
                maxScale: maxScale
            )
        )
    }
}

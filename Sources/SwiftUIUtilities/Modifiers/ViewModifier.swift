//
//  File.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 14/11/25.
//

import SwiftUI

public struct CustomViewModifier {
    struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    
    struct VersionedLineLimitModifier: ViewModifier {
        let lineLimit: Int
        let reservesSpace: Bool

        @ViewBuilder
        func body(content: Content) -> some View {
            if #available(iOS 16, *) {
                content.lineLimit(lineLimit, reservesSpace: reservesSpace)
            } else {
                content.lineLimit(lineLimit)
            }
        }
    }
    
    
    struct VersionedContentMargins: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 17.0, *) {
                // Use contentMargins on iOS 17 or later
                content
                    .contentMargins(.all, 10, for: .scrollContent)
                    .contentMargins(.top, -10, for: .scrollIndicators)
            } else {
                // Fallback to padding for earlier versions
                content
                    .padding(10)
            }
        }
    }
    
    
    ///
    /// ------------------------------------------------   ` <<<<<<<<< Background gradient Modifier  >>>>>>>>>>>>>>`   -----------------------------------------------------------------------------
    ///
    struct GradientBackgroundModifier: ViewModifier {
        let stops: [Gradient.Stop]
        let startPoint: UnitPoint
        let endPoint: UnitPoint

        init(
            stops: [Gradient.Stop] = [
                .init(color: Color.blue, location: 0.0),
                .init(color: Color.blue.opacity(0.7), location: 0.5),
                .init(color: Color.gray.opacity(0.3), location: 0.8),
                .init(color: Color.gray, location: 1.0)
            ],
            startPoint: UnitPoint = .top,
            endPoint: UnitPoint = .bottom
        ) {
            self.stops = stops
            self.startPoint = startPoint
            self.endPoint = endPoint
        }

        func body(content: Content) -> some View {
            content
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: stops),
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                    .ignoresSafeArea() // Extend to fill the safe area
                )
        }
    }
    
    
    struct DisabledOpacityModifier: ViewModifier {
        let isDisabled: Bool

        func body(content: Content) -> some View {
            content
                .opacity(isDisabled ? 0.5 : 1.0) // Apply reduced opacity if disabled
                .disabled(isDisabled)           // Disable interaction if needed
        }
    }

    struct GradientBorderModifier: ViewModifier {
        var cornerRadius: CGFloat = 20
        var lineWidth: CGFloat = 2
        var gradientColors: [Color] = [
            Color(hex: "#00D9FF"), // Cyan
            Color(hex: "#00FFB3"), // Teal/Green
            Color(hex: "#00D9FF")  // Cyan
        ]
        
        func body(content: Content) -> some View {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: lineWidth
                        )
                )
        }
    }

    
    struct VersionedHorizontalContentMargins: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 17.0, *) {
                // Use contentMargins without negative padding
                content
                    .contentMargins(.horizontal,10)
                    .contentMargins(.top, -10, for: .scrollIndicators)
            } else {
                // Fallback to standard padding for earlier versions
                content
                    .padding(.horizontal, 10)
            }
        }
    }
    
    struct VersionedHorizontalBottomContentMargins: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 17.0, *) {
                // Use contentMargins without negative padding
                content
                    .contentMargins(.bottom,10)
                    .contentMargins(.horizontal,10)
                    .contentMargins(.horizontal, -10, for: .scrollIndicators)
            } else {
                // Fallback to standard padding for earlier versions
                content
                    .padding(.bottom, 10)
                    .padding(.horizontal, 10)
            }
        }
    }

    
    struct CardViewModifier: ViewModifier {  // Conforming to ViewModifier protocol
        var backgroundColor: SwiftUI.Color = .white
        var cornerRadius: CGFloat = 10
        var shadowColor: SwiftUI.Color = .black.opacity(0.2)
        var shadowRadius: CGFloat = 10
        var padding: CGFloat = 16
        var borderWidth: CGFloat = 0
        var borderColor: SwiftUI.Color = .clear

        func body(content: Content) -> some View {
            content
                .padding(padding)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .shadow(color: shadowColor, radius: shadowRadius)
        }
    }
    
    struct DynamicTextColor: ViewModifier {
        let backgroundColor: Color
        
        func body(content: Content) -> some View {
            content
                .foregroundColor(backgroundColor.contrastingTextColor())
        }
    }
    
    struct FontStyleModifier: ViewModifier {
        let fontStyle: SwiftUIUtilityModel.FontStyle
        
        func body(content: Content) -> some View {
            switch fontStyle {
            case .system(let font):
                content.font(font)
            case .custom(let customFont, let size, let weight):
                content.appFont(customFont, size: size, weight: weight)
            }
        }
    }
    
    struct CustomBackButtonModifier: ViewModifier {
        let title: String?
        let navTitle: String?
        let navTitileImage: String? // Image name for SF Symbol or Asset
        let action: () -> Void
        
        func body(content: Content) -> some View {
            content
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: action) {
                            HStack(spacing: 2) {
                                Image(systemName: "chevron.left")
                                Text(title ?? "toolbar_back_title".localized) // Customizable text
                            }
                            .foregroundStyle(.black)
                        }
                        .offset(x: -8)
                    }
                    
                    ToolbarItem(placement: .principal) {
                        principalView
                    }
                }
        }
        
        private var principalView: some View {
            HStack(spacing: 8) {
                if let imageName = navTitileImage {
                    if UIImage(systemName: imageName) != nil {
                        // Load as SF Symbol
                        Image(systemName: imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    } else {
                        // Load as Asset Image
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                    }
                }
                
                if let navTitle = navTitle {
                    Text(navTitle)
                        .font(.headline)
                }
            }
        }
    }
    
    /// ------------------------------------------------   ` <<<<<<<<< Shimmer  View Modifier  >>>>>>>>>>>>>>`   -----------------------------------------------------------------------------


    struct StateDrivenView<Content: View, LoadingContent: View, EmptyContent: View>: View {
        let loadingState: LoadingState?
        let emptyState: EmptyStateData?
        let content: () -> Content
        let loadingContent: () -> LoadingContent
        let emptyContent: (EmptyStateData) -> EmptyContent
        
        init(loadingState: LoadingState?,
             emptyState: EmptyStateData?,
             @ViewBuilder content: @escaping () -> Content,
             @ViewBuilder loadingContent: @escaping () -> LoadingContent,
             @ViewBuilder emptyContent: @escaping (EmptyStateData) -> EmptyContent) {
            self.loadingState = loadingState
            self.emptyState = emptyState
            self.content = content
            self.loadingContent = loadingContent
            self.emptyContent = emptyContent
        }
        
        var body: some View {
            Group {
                switch (loadingState, emptyState) {
                    
                case (.some(.loading(_, _, _)), _), (.some(.progressLoading(_, _, _, _)), _):
                    loadingContent()
                    
                case (_, .some(.noData)):
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView { emptyContent(.noData) }
                    } else {
                        emptyContent(.noData)
                    }
                    
                case (.some(.loaded), .some(.none)):
                    content()
                    
                default:
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView { emptyContent(emptyState ?? .error) }
                    } else {
                        emptyContent(emptyState ?? .error)
                    }
                }
            }
        }
    }
    
    
    struct MatchToParentContainer: ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

}



public extension View {
    // MARK: - Full Size with Alignment
    
    func fullSize(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    // MARK: - Corner Positions
    
    func topLeading() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func topTrailing() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    func bottomLeading() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    
    func bottomTrailing() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    
    // MARK: - Edge Positions
    
    func top() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    func bottom() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    func leading() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    func trailing() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
    
    // MARK: - Center Positions
    
    func center() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    func centerHorizontally() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }
    
    func centerVertically() -> some View {
        self.frame(maxHeight: .infinity, alignment: .center)
    }
    
    
    
    //MARK: UI Border Related Extension
    
    /// Modifier for rounding specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CustomViewModifier.RoundedCorner(radius: radius, corners: corners))
    }
    
    
    
    //MARK: View Background Related Modifier
    
    
    
    
    func versionedLineLimit(_ lineLimit: Int = 1, reservesSpace: Bool = true) -> some View {
        self.modifier(CustomViewModifier.VersionedLineLimitModifier(lineLimit: lineLimit, reservesSpace: reservesSpace))
    }
    
    func versionedContentMargins() -> some View {
        self.modifier(CustomViewModifier.VersionedContentMargins())
    }
    
    
    @ViewBuilder
    func applyScrollBounceBehavior() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        } else {
            self // No-op for iOS 15 or earlier
        }
    }
    
    
    /// Attaches a reusable, customizable gradient background to any view.
    ///
    /// - Parameters:
    ///   - stops: An array of `Gradient.Stop` values defining the colors and locations.
    ///   - startPoint: The starting point of the gradient (default is `.top`).
    ///   - endPoint: The ending point of the gradient (default is `.bottom`).
    /// - Returns: A view with the gradient background applied.
    func reusableGradientBackground(
        stops: [Gradient.Stop]? = nil,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> some View {
        // Use custom stops if provided; otherwise, use the default stops.
        let gradientStops = stops ?? [
            .init(color: Color.blue, location: 0.0),
            .init(color: Color.blue.opacity(0.7), location: 0.5),
            .init(color: Color.gray.opacity(0.3), location: 0.8),
            .init(color: Color.gray, location: 1.0)
        ]
        return self.modifier(CustomViewModifier.GradientBackgroundModifier(stops: gradientStops, startPoint: startPoint, endPoint: endPoint))
    }
   
    func disabledWithOpacity(_ isDisabled: Bool) -> some View {
        self.modifier(CustomViewModifier.DisabledOpacityModifier(isDisabled: isDisabled))
    }
    
    func gradientBorder(
        cornerRadius: CGFloat = 20,
        lineWidth: CGFloat = 2,
        colors: [Color] = [
            .white.opacity(0.7),
            .gray.opacity(0.3),
            .clear
        ]
    ) -> some View {
        self.modifier(CustomViewModifier.GradientBorderModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            gradientColors: colors
        ))
    }
    
    
    func versionedHorizontalContentMargins() -> some View {
        self.modifier(CustomViewModifier.VersionedHorizontalContentMargins())
    }
    
    
    func versionedHorizontalBottomContentMargins() -> some View {
        self.modifier(CustomViewModifier.VersionedHorizontalBottomContentMargins())
    }
    
    func cardStyle(
        backgroundColor: SwiftUI.Color = .white,
        cornerRadius: CGFloat = 10,
        shadowColor: SwiftUI.Color = .black.opacity(0.2),
        shadowRadius: CGFloat = 10,
        padding: CGFloat = 16,
        borderWidth: CGFloat = 0,
        borderColor: SwiftUI.Color = .clear
    ) -> some View {
        self.modifier(CustomViewModifier.CardViewModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowColor: shadowColor,
            shadowRadius: shadowRadius,
            padding: padding,
            borderWidth: borderWidth,
            borderColor: borderColor
        ))
    }
    
    func dynamicTextColor(for background: Color) -> some View {
        self.modifier(CustomViewModifier.DynamicTextColor(backgroundColor: background))
    }
    
    func fontStyle(_ style: SwiftUIUtilityModel.FontStyle) -> some View {
        modifier(CustomViewModifier.FontStyleModifier(fontStyle: style))
    }
    
    
    func customBackButton(title: String? = nil, navTitle: String? = nil, navTitileImage: String? = nil,  action: @escaping () -> Void) -> some View {
        self.modifier(CustomViewModifier.CustomBackButtonModifier(title:title,navTitle: navTitle,navTitileImage: navTitileImage,action: action))
    }
    
    func stateDrivenView<LoadingContent: View, EmptyContent: View>(
        loadingState: LoadingState?,
        emptyState: EmptyStateData?,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent,
        @ViewBuilder emptyContent: @escaping (EmptyStateData) -> EmptyContent
    ) -> some View {
        CustomViewModifier.StateDrivenView(
            loadingState: loadingState,
            emptyState: emptyState,
            content: { self },
            loadingContent: loadingContent,
            emptyContent: emptyContent
        )
    }
    
    
    func matchToParentContainer() -> some View {
        self.modifier(CustomViewModifier.MatchToParentContainer())
    }
}
// MARK: - Package-prefixed View Extensions (to avoid name collisions)

public extension View {
    // MARK: - Full Size with Alignment
    
    func fullSizePkg(alignment: Alignment = .center) -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    // MARK: - Corner Positions
    
    func topLeadingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func topTrailingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
    
    func bottomLeadingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    
    func bottomTrailingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
    
    // MARK: - Edge Positions
    
    func topPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    func bottomPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
    
    func leadingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    func trailingPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    }
    
    // MARK: - Center Positions
    
    func centerPkg() -> some View {
        self.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    func centerHorizontallyPkg() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }
    
    func centerVerticallyPkg() -> some View {
        self.frame(maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - UI Border Related Extension
    
    /// Modifier for rounding specific corners
    func cornerRadiusPkg(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CustomViewModifier.RoundedCorner(radius: radius, corners: corners))
    }
    
    // MARK: - View Background Related Modifier
    
    func versionedLineLimitPkg(_ lineLimit: Int = 1, reservesSpace: Bool = true) -> some View {
        self.modifier(CustomViewModifier.VersionedLineLimitModifier(lineLimit: lineLimit, reservesSpace: reservesSpace))
    }
    
    func versionedContentMarginsPkg() -> some View {
        self.modifier(CustomViewModifier.VersionedContentMargins())
    }
    
    @ViewBuilder
    func applyScrollBounceBehaviorPkg() -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(.basedOnSize, axes: [.vertical])
        } else {
            self // No-op for iOS 15 or earlier
        }
    }
    
    /// Attaches a reusable, customizable gradient background to any view.
    ///
    /// - Parameters:
    ///   - stops: An array of `Gradient.Stop` values defining the colors and locations.
    ///   - startPoint: The starting point of the gradient (default is `.top`).
    ///   - endPoint: The ending point of the gradient (default is `.bottom`).
    /// - Returns: A view with the gradient background applied.
    func reusableGradientBackgroundPkg(
        stops: [Gradient.Stop]? = nil,
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom
    ) -> some View {
        // Use custom stops if provided; otherwise, use the default stops.
        let gradientStops = stops ?? [
            .init(color: Color.blue, location: 0.0),
            .init(color: Color.blue.opacity(0.7), location: 0.5),
            .init(color: Color.gray.opacity(0.3), location: 0.8),
            .init(color: Color.gray, location: 1.0)
        ]
        return self.modifier(CustomViewModifier.GradientBackgroundModifier(stops: gradientStops, startPoint: startPoint, endPoint: endPoint))
    }
   
    func disabledWithOpacityPkg(_ isDisabled: Bool) -> some View {
        self.modifier(CustomViewModifier.DisabledOpacityModifier(isDisabled: isDisabled))
    }
    
    func gradientBorderPkg(
        cornerRadius: CGFloat = 20,
        lineWidth: CGFloat = 2,
        colors: [Color] = [
            .white.opacity(0.7),
            .gray.opacity(0.3),
            .clear
        ]
    ) -> some View {
        self.modifier(CustomViewModifier.GradientBorderModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            gradientColors: colors
        ))
    }
    
    func versionedHorizontalContentMarginsPkg() -> some View {
        self.modifier(CustomViewModifier.VersionedHorizontalContentMargins())
    }
    
    func versionedHorizontalBottomContentMarginsPkg() -> some View {
        self.modifier(CustomViewModifier.VersionedHorizontalBottomContentMargins())
    }
    
    func cardStylePkg(
        backgroundColor: SwiftUI.Color = .white,
        cornerRadius: CGFloat = 10,
        shadowColor: SwiftUI.Color = .black.opacity(0.2),
        shadowRadius: CGFloat = 10,
        padding: CGFloat = 16,
        borderWidth: CGFloat = 0,
        borderColor: SwiftUI.Color = .clear
    ) -> some View {
        self.modifier(CustomViewModifier.CardViewModifier(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowColor: shadowColor,
            shadowRadius: shadowRadius,
            padding: padding,
            borderWidth: borderWidth,
            borderColor: borderColor
        ))
    }
    
    func dynamicTextColorPkg(for background: Color) -> some View {
        self.modifier(CustomViewModifier.DynamicTextColor(backgroundColor: background))
    }
    
    func fontStylePkg(_ style: SwiftUIUtilityModel.FontStyle) -> some View {
        modifier(CustomViewModifier.FontStyleModifier(fontStyle: style))
    }
    
    func customBackButtonPkg(title: String? = nil, navTitle: String? = nil, navTitileImage: String? = nil, action: @escaping () -> Void) -> some View {
        self.modifier(CustomViewModifier.CustomBackButtonModifier(title: title, navTitle: navTitle, navTitileImage: navTitileImage, action: action))
    }
    
    func stateDrivenViewPkg<LoadingContent: View, EmptyContent: View>(
        loadingState: LoadingState?,
        emptyState: EmptyStateData?,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent,
        @ViewBuilder emptyContent: @escaping (EmptyStateData) -> EmptyContent
    ) -> some View {
        CustomViewModifier.StateDrivenView(
            loadingState: loadingState,
            emptyState: emptyState,
            content: { self },
            loadingContent: loadingContent,
            emptyContent: emptyContent
        )
    }
    
    func matchToParentContainerPkg() -> some View {
        self.modifier(CustomViewModifier.MatchToParentContainer())
    }
}


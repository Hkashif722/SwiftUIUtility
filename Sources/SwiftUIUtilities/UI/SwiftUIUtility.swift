//
//  SwiftUIUtility.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 14/11/25.
//

import SwiftUI


public struct SwiftUIUtility {
    
    public struct BackgroundImageView: View {
        public let imageName: String
        public var contentMode: ContentMode = .fit
        
        public init(imageName: String, contentMode: ContentMode = .fit) {
            self.imageName = imageName
            self.contentMode = contentMode
        }
        
        public var body: some View {
            Image(imageName, bundle: .swiftUIUtilitiesModule)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Gradient Divider Utility
    public struct GradientDivider: View {
        public let colors: [Color]
        public let height: CGFloat
        public let startPoint: UnitPoint
        public let endPoint: UnitPoint
        public let horizontalPadding: CGFloat
        
        public init(
            colors: [Color] = [.white.opacity(0.1), .white.opacity(0.9), .white.opacity(0.1)],
            height: CGFloat = 2,
            startPoint: UnitPoint = .leading,
            endPoint: UnitPoint = .trailing,
            horizontalPadding: CGFloat = 2
        ) {
            self.colors = colors
            self.height = height
            self.startPoint = startPoint
            self.endPoint = endPoint
            self.horizontalPadding = horizontalPadding
        }
        
        public var body: some View {
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    public struct RoundMenuButton: View  {
        
        public enum RoundMenuButtonImage {
            case system(name: String)
            case asset(name: String)
        }
        
        // Use our enum to support both image types
        public var image: RoundMenuButtonImage
        
        public var buttonSize: CGFloat = 80
        public var imagePadding: CGFloat = 15
        public var foregroundColor: Color = .black
        public var backgroundColor: Color = Color(.systemBackground)
        public var shadowColor: Color = Color.gray.opacity(0.4)
        public var shadowRadius: CGFloat = 5
        public var isAnimating: Bool = false
        
        // Action closure for the button
        public var action: () -> Void
        
        public init(
            image: RoundMenuButtonImage,
            buttonSize: CGFloat = 80,
            imagePadding: CGFloat = 15,
            foregroundColor: Color = .black,
            backgroundColor: Color = Color(.systemBackground),
            shadowColor: Color = Color.gray.opacity(0.4),
            shadowRadius: CGFloat = 5,
            isAnimating: Bool = false,
            action: @escaping () -> Void
        ) {
            self.image = image
            self.buttonSize = buttonSize
            self.imagePadding = imagePadding
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
            self.shadowColor = shadowColor
            self.shadowRadius = shadowRadius
            self.isAnimating = isAnimating
            self.action = action
        }
        
        public var body: some View {
            Button(action: action) {
                Circle()
                    .foregroundColor(.clear)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(backgroundColor)
                    .clipShape(Circle())
                    .shadow(color: shadowColor, radius: shadowRadius)
                    .overlay(
                        Group {
                            switch image {
                            case .system(let name):
                                Image(systemName: name)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(foregroundColor)
                                    .padding(imagePadding)
                            case .asset(let name):
                                Image(name, bundle: .swiftUIUtilitiesModule)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(imagePadding)
                            }
                        }
                        
                    )
                    .padding(10)
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    

    public struct ProfileImageViewWithGradientBorder: View {
        public let imageUrl: URL?
        public let size: CGFloat
        public var gradientColors: [Color] = [.blue, .purple]
        public var borderWidth: CGFloat = 2
        public var placeHolderImageUrlString: String =
            "https://content.gogetempowered.com/assets/img/Thumbnail_vectors/img_thumb60.jpg"
        
        public init(
            imageUrl: URL?,
            size: CGFloat,
            gradientColors: [Color] = [.blue, .purple],
            borderWidth: CGFloat = 2,
            placeHolderImageUrlString: String = "https://content.gogetempowered.com/assets/img/Thumbnail_vectors/img_thumb60.jpg"
        ) {
            self.imageUrl = imageUrl
            self.size = size
            self.gradientColors = gradientColors
            self.borderWidth = borderWidth
            self.placeHolderImageUrlString = placeHolderImageUrlString
        }
        
        public var placeholder: some View {
            AsyncImage(url: URL(string: placeHolderImageUrlString)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2) // backup placeholder
            }
        }

        public var body: some View {
            AsyncImage(url: imageUrl) { phase in
                
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                    
                case .failure(_):
                    placeholder
                    
                case .empty:
                    placeholder
                    
                @unknown default:
                    placeholder
                }
                
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: borderWidth
                )
            )
        }
    }


    public struct ProfileImageViewWithVariableCorner: View {
        public let imageUrl: URL?
        public let size: CGFloat
        public let cornerRadius: CGFloat
        public var profileBorderColor: Color? = nil
        public var borderWidth: CGFloat
        public var placeHolderImageUrlString: String
        
        public init(
            imageUrl: URL?,
            size: CGFloat,
            cornerRadius: CGFloat = 10,
            profileBorderColor: Color? = nil,
            borderWidth: CGFloat = 2,
            placeHolderImageUrlString: String =
                "https://content.gogetempowered.com/assets/img/Thumbnail_vectors/img_thumb60.jpg"
        ) {
            self.imageUrl = imageUrl
            self.size = size
            self.cornerRadius = cornerRadius
            self.profileBorderColor = profileBorderColor
            self.borderWidth = borderWidth
            self.placeHolderImageUrlString = placeHolderImageUrlString
        }
        
        // Placeholder view (remote placeholder image)
        private var placeholderView: some View {
            AsyncImage(url: URL(string: placeHolderImageUrlString)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
        }
        
        public var body: some View {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                    
                case .failure(_):
                    placeholderView
                    
                case .empty:
                    placeholderView
                    
                @unknown default:
                    placeholderView
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        profileBorderColor ?? .clear,
                        lineWidth: profileBorderColor != nil ? borderWidth : 0
                    )
            )
        }
    }
    
    
    public struct RectangularGradientButton: View {
        public var title: String? = nil
        public var iconName: String? = nil
        public var isSystemIcon: Bool = true
        public var gradient: LinearGradient
        public var foregroundColor: Color = .white
        public var borderColor: Color? = nil
        public var borderWidth: CGFloat = 1.5
        public var cornerRadius: CGFloat = 10
        public var height: CGFloat = 50
        public var font: Font = .headline
        public var action: () -> Void

        public init(
            title: String? = nil,
            iconName: String? = nil,
            isSystemIcon: Bool = true,
            gradient: LinearGradient,
            foregroundColor: Color = .white,
            borderColor: Color? = nil,
            borderWidth: CGFloat = 1.5,
            cornerRadius: CGFloat = 10,
            height: CGFloat = 50,
            font: Font = .headline,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.iconName = iconName
            self.isSystemIcon = isSystemIcon
            self.gradient = gradient
            self.foregroundColor = foregroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.height = height
            self.font = font
            self.action = action
        }

        public var body: some View {
            Button(action: action) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(gradient)
                    .frame(height: height)
                    .overlay {
                        if let borderColor = borderColor {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: borderWidth)
                        }
                    }
                    .overlay {
                        HStack(spacing: 8) {
                            if let iconName = iconName {
                                (isSystemIcon
                                 ? Image(systemName: iconName)
                                 : Image(iconName, bundle: .swiftUIUtilitiesModule))
                                .foregroundStyle(foregroundColor)
                            }

                            if let title = title {
                                Text(title)
                                    .font(font)
                                    .foregroundStyle(foregroundColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.3)
                                    .allowsTightening(true)
                            }
                        }
                        .padding(5)
                    }
            }
            .font(font)
        }
    }
    
    public struct RectangularIconButtonWithBorder: View {
        public var title: String? = nil
        public var iconName: String? = nil
        public var isSystemIcon: Bool = true
        public var backgroundColor: SwiftUI.Color = .clear
        public var foregroundColor: Color = ColorUtility.primaryColor
        public var borderColor: Color = ColorUtility.primaryColor
        public var borderWidth: CGFloat = 1.5
        public var cornerRadius: CGFloat = 10
        public var height: CGFloat = 50
        public var font: Font = .headline
        public var action: () -> Void
        
        public init(
            title: String? = nil,
            iconName: String? = nil,
            isSystemIcon: Bool = true,
            backgroundColor: SwiftUI.Color = .clear,
            foregroundColor: Color = ColorUtility.primaryColor,
            borderColor: Color = ColorUtility.primaryColor,
            borderWidth: CGFloat = 1.5,
            cornerRadius: CGFloat = 10,
            height: CGFloat = 50,
            font: Font = .headline,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.iconName = iconName
            self.isSystemIcon = isSystemIcon
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.height = height
            self.font = font
            self.action = action
        }
        
        public var body: some View {
            Button(action: action) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                    .overlay {
                        HStack(spacing: 8) {
                            if let iconName = iconName {
                                (isSystemIcon
                                 ? Image(systemName: iconName)
                                 : Image(iconName,bundle: .swiftUIUtilitiesModule))
                                .foregroundStyle(foregroundColor)
                            }
                            if let title = title {
                                Text(title)
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(foregroundColor)
                            }
                        }
                        .padding(.all, 5)
                        .padding(.horizontal, 5)
                    }
            }
            .font(font)
        }
    }
    
    
    public struct CircularProgressView: View {
        /// A value between 0.0 and 1.0.
        public var progress: Double
        /// The line width for the progress circle.
        public var lineWidth: CGFloat = 10.0
        /// The size of the circular progress view.
        public var size: CGFloat = 100.0
        /// Optional gradient colors. If nil, uses solid color.
        public var gradientColors: [Color]?
        /// Solid color used when gradientColors is nil.
        public var solidColor: Color = ColorUtility.primaryColor
        /// Show or hide percentage text.
        public var showPercentage: Bool = true
        /// Custom text color. If nil, uses .primary.
        public var textColor: Color?
        /// Custom font for percentage text.
        public var font: Font = .headline
        
        
        /// Creates a circular progress view with gradient colors.
        public init(
            progress: Double,
            gradientColors: [Color]? = nil,
            lineWidth: CGFloat = 10.0,
            size: CGFloat = 100.0,
            showPercentage: Bool = true,
            textColor: Color? = nil,
            font: Font = .headline
        ) {
            self.progress = progress
            self.gradientColors = gradientColors
            self.lineWidth = lineWidth
            self.size = size
            self.showPercentage = showPercentage
            self.textColor = textColor
            self.font = font
        }
        
        public var body: some View {
            ZStack {
                // Background track circle
                Circle()
                    .stroke(
                        backgroundStroke,
                        lineWidth: lineWidth
                    )
                    .frame(width: size, height: size)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressStroke,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(gradientColors != nil ? .degrees(-85) : .degrees(-90))
                    .frame(width: size, height: size)
                    .animation(.linear, value: progress)
                
                // Center text showing percentage
                if showPercentage {
                    Text(String(format: "%.0f%%", progress * 100))
                        .font(font)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(textColor ?? .primary)
                }
            }
        }
        
        // MARK: - Computed Properties
        
        private var backgroundStroke: some ShapeStyle {
            if let gradientColors = gradientColors {
                return AnyShapeStyle(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).opacity(0.2)
                )
            } else {
                return AnyShapeStyle(Color.gray.opacity(0.3))
            }
        }

        private var progressStroke: some ShapeStyle {
            if let gradientColors = gradientColors {
                return AnyShapeStyle(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(355)
                    )
                )
            } else {
                return AnyShapeStyle(solidColor)
            }
        }

    }
    
    
    public struct IconWithText: View {
        public var imageName: String?
        public var imageSize: CGSize
        public var text: String
        public var isSystemImage: Bool = true
        public var isSelectionType: Bool = false
        public var font: Font.Custom = .inter
        public var fontSize: CGFloat = 18
        public var fontWeight: Font.Weight = .medium
        public var iconColor: Color = .primary
        public var textColor: Color = .primary
        public var spacing: CGFloat = 8
        public var rendringMode: Image.TemplateRenderingMode? = .template

        public let onTap: (() -> ())?

        public init(
            imageName: String? = nil,
            imageSize: CGSize = CGSize(width: 24, height: 24),
            text: String,
            isSystemImage: Bool = true,
            isSelectionType: Bool = false,
            font: Font.Custom = .inter,
            fontSize: CGFloat,
            fontWeight: Font.Weight,
            iconColor: Color = .primary,
            textColor: Color = .primary,
            spacing: CGFloat = 8,
            rendringMode: Image.TemplateRenderingMode? = nil,
            onTap: (() -> Void)? = nil
        ) {
            self.imageName = imageName
            self.imageSize = imageSize
            self.text = text
            self.isSystemImage = isSystemImage
            self.isSelectionType = isSelectionType
            self.font = font
            self.fontSize = fontSize
            self.fontWeight = fontWeight
            self.iconColor = iconColor
            self.textColor = textColor
            self.spacing = spacing
            self.rendringMode = rendringMode
            self.onTap = onTap
        }

        public var body: some View {
            HStack(spacing: spacing) {
                
                if let safeImage = imageName {
                    if isSystemImage {
                        Image(systemName: safeImage)
                            .foregroundColor(iconColor)
                            .frame(width: imageSize.width, height: imageSize.height)
                    } else {
                        Image(safeImage, bundle: .swiftUIUtilitiesModule)
                            .resizable()
                            .renderingMode(rendringMode)
                            .scaledToFit()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .foregroundColor(iconColor)
                    }
                }

                Text(text)
                    .foregroundColor(textColor)
                    .appFont(font, size: fontSize, weight: fontWeight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .allowsTightening(true)

                if isSelectionType {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
        }
    }

    
    // MARK: - Profile Image View
    public struct ProfileImageView: View {
        public let imageUrl: URL?
        public let size: CGFloat
        public var profileBorderColor: SwiftUI.Color? = nil
        public var borderWidth: CGFloat = 2
        public var placeHolderImageUrlString: String =
            "https://content.gogetempowered.com/assets/img/Thumbnail_vectors/img_thumb60.jpg"
        
        public init(
            imageUrl: URL?,
            size: CGFloat,
            profileBorderColor: SwiftUI.Color? = nil,
            borderWidth: CGFloat = 2,
            placeHolderImageUrlString: String = "https://content.gogetempowered.com/assets/img/Thumbnail_vectors/img_thumb60.jpg"
        ) {
            self.imageUrl = imageUrl
            self.size = size
            self.profileBorderColor = profileBorderColor
            self.borderWidth = borderWidth
            self.placeHolderImageUrlString = placeHolderImageUrlString
        }
        
        public var body: some View {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    AsyncImage(url: URL(string: placeHolderImageUrlString)) { imgPhase in
                        (imgPhase.image ?? Image(systemName: "person.circle"))
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(profileBorderColor ?? .clear,
                                lineWidth: profileBorderColor != nil ? borderWidth : 0)
            )
        }
    }
    
    
    // MARK: - RectangularIconButton
    public struct RectangularIconButton: View {
        public var title: String? = nil
        public var iconName: String? = nil
        public var isSystemIcon: Bool = true
        public var renderingMode: Image.TemplateRenderingMode = .original
        public var backgroundColor: SwiftUI.Color = ColorUtility.primaryColor
        public var foregroundColor: Color = Color(.label)
        public var cornerRadius: CGFloat = 10
        public var height: CGFloat = 50
        public var fontStyle: SwiftUIUtilityModel.FontStyle = .custom(.inter, size: 16, weight: .regular)
        public var action: () -> Void
        
        public init(
            title: String? = nil,
            iconName: String? = nil,
            isSystemIcon: Bool = true,
            renderingMode: Image.TemplateRenderingMode = .original,
            backgroundColor: SwiftUI.Color = ColorUtility.primaryColor,
            foregroundColor: Color = Color(.label),
            cornerRadius: CGFloat = 10,
            height: CGFloat = 50,
            fontStyle: SwiftUIUtilityModel.FontStyle = .custom(.inter, size: 16, weight: .regular),
            action: @escaping () -> Void
        ) {
            self.title = title
            self.iconName = iconName
            self.isSystemIcon = isSystemIcon
            self.renderingMode = renderingMode
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.cornerRadius = cornerRadius
            self.height = height
            self.fontStyle = fontStyle
            self.action = action
        }
        
        public var body: some View {
            Button(action: action) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(backgroundColor)
                    .frame(height: height)
                    .overlay {
                        HStack(spacing: 8) {
                            if let iconName = iconName {
                                (isSystemIcon
                                 ? Image(systemName: iconName)
                                 : Image(iconName, bundle: .swiftUIUtilitiesModule)
                                    .renderingMode(renderingMode))  // Apply it here
                                    .foregroundStyle(foregroundColor)
                            }
                            if let title = title {
                                Text(title)
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(foregroundColor)
                            }
                        }
                        .padding(.all, 5)
                        .padding(.horizontal, 5)
                    }
            }
            .fontStyle(fontStyle)
        }
    }
    
    public struct PaddedDivider: View {
        
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        
        public init(horizontalPadding: CGFloat = 0, verticalPadding: CGFloat = 0) {
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
        }
        
        public var body: some View {
            Divider()
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
        }
        
    }

    public struct CustomToggle: View {
        @Binding var isOn: Bool
        
        // Customizable properties
        var onColor: Color
        var offColor: Color
        var knobColor: Color
        var onLabel: String
        var offLabel: String
        var width: CGFloat
        var height: CGFloat
        var labelFont: Font
        var animationDuration: Double
        
        public init(
            isOn: Binding<Bool>,
            onColor: Color = ColorUtility.primaryColor,
            offColor: Color = ColorUtility.secondaryColor,
            knobColor: Color = .white,
            onLabel: String = "ON",
            offLabel: String = "OFF",
            width: CGFloat = 100,
            height: CGFloat = 40,
            labelFont: Font = .system(size: 20, weight: .bold),
            animationDuration: Double = 0.3
        ) {
            self._isOn = isOn
            self.onColor = onColor
            self.offColor = offColor
            self.knobColor = knobColor
            self.onLabel = onLabel
            self.offLabel = offLabel
            self.width = width
            self.height = height
            self.labelFont = labelFont
            self.animationDuration = animationDuration
        }
        
        private var knobSize: CGFloat {
            height - 14
        }
        
        private var knobPadding: CGFloat {
            7
        }
        
        public var body: some View {
            ZStack {
                // Background capsule
                Capsule()
                    .fill(isOn ? onColor : offColor)
                    .frame(width: width, height: height)
                
                // Label positioned in the visible area
                HStack {
                    Text(isOn ? onLabel : offLabel)
                        .font(labelFont)
                        .foregroundColor(
                            isOn
                            ? onColor.getDynamicTextColor
                            : offColor.getDynamicTextColor
                        )
                        .frame(maxWidth: .infinity, alignment: isOn ? .leading : .trailing)
                }
                .padding(15)
                .frame(width: width)
                
                // Knob
                HStack {
                    if isOn {
                        Spacer()
                    }
                    
                    Circle()
                        .fill(knobColor)
                        .frame(width: knobSize, height: knobSize)
                        .padding(knobPadding)
                    
                    if !isOn {
                        Spacer()
                    }
                }
                .frame(width: width)
            }
            .frame(width: width, height: height)
            .onTapGesture {
                withAnimation(.spring(response: animationDuration, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
    }

    public struct FlexibleGridView<Content: View>: View {
        private let content: Content
        private let columns: [GridItem]
        private let spacing: CGFloat
        
        public init(columns: Int = 2, spacing: CGFloat = 10, @ViewBuilder content: () -> Content) {
            self.content = content()
            self.spacing = spacing
            self.columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
        }
        
        public var body: some View {
            LazyVGrid(columns: columns, spacing: spacing) {
                content
            }
        }
    }

    
}

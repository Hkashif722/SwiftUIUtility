//
//  CustomAlertPopupView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import SwiftUI
import SwiftfulRouting

// MARK: - Alert Type Enum
public enum AlertType: String, Codable {
    case success
    case warning
    case error
    case info
    case none

    @ViewBuilder
    public var icon: some View {
        switch self {
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.green)
        case .warning:
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.yellow)
        case .error:
            Image(systemName: "xmark.octagon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
        case .info:
            Image(systemName: "info.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Model for Custom Alert Pop-Up
public struct CustomAlertPopupModel {
    let title: AttributedString
    let content: AnyView
    let alertType: AlertType
    let primaryButtonTitle: String
    let primaryAction: (() -> Void)?
    let secondaryButtonTitle: String?
    let secondaryAction: (() -> Void)?

    public init<Content: View>(
        title: AttributedString,
        alertType: AlertType,
        @ViewBuilder content: () -> Content,
        primaryButtonTitle: String,
        primaryAction: (() -> Void)? = nil,
        secondaryButtonTitle: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.alertType = alertType
        self.content = AnyView(content())
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryAction = secondaryAction
    }
}

// MARK: - Alert Pop-Up View
public struct CustomAlertPopupView: View {
    let model: CustomAlertPopupModel

    public init(model: CustomAlertPopupModel) {
        self.model = model
    }

    public var body: some View {
        VStack(spacing: 15) {
            model.alertType.icon
            headerTitleView
            model.content

            Divider()

            HStack(spacing: 16) {
                secondaryButtonView
                primaryButtonView
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
        .padding()
        .background(ColorUtility.viewBackgroundColorSecondary)
        .cornerRadius(20)
        .transition(.scale)
        .padding(.horizontal)
    }

    private var headerTitleView: some View {
        Text(model.title)
            .font(.title2)
            .foregroundStyle(ColorUtility.deepBlue)
    }

    @ViewBuilder
    private var secondaryButtonView: some View {
        if let secondaryButtonTitle = model.secondaryButtonTitle {
            SwiftUIUtility.RectangularIconButton(
                title: secondaryButtonTitle,
                backgroundColor: ColorUtility.secondaryColor,
                foregroundColor: .black,
                height: 45
            ) {
                model.secondaryAction?()
            }
            .minimumScaleFactor(0.8)
        }
    }

    private var primaryButtonView: some View {
        SwiftUIUtility.RectangularIconButton(
            title: model.primaryButtonTitle,
            backgroundColor: ColorUtility.primaryColor,
            foregroundColor: .white,
            height: 45
        ) {
            model.primaryAction?()
        }
        .minimumScaleFactor(0.8)
    }
}

// MARK: - Factory Methods for Alerts
public extension CustomAlertPopupModel {
    static func success(
        message: AttributedString,
        messageAlignment: TextAlignment = .center,
        primaryButtonTitle: String = "OK",
        primaryAction: (() -> Void)? = nil
    ) -> CustomAlertPopupModel {
        return CustomAlertPopupModel(
            title: "Success",
            alertType: .success,
            content: {
                Text(message)
                    .multilineTextAlignment(messageAlignment)
                    .padding()
            },
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction
        )
    }

    static func warning(
        title: AttributedString = AttributedString("Warning"),
        message: AttributedString,
        messageAlignment: TextAlignment = .center,
        primaryButtonTitle: String = "Proceed",
        primaryAction: (() -> Void)? = nil,
        secondaryButtonTitle: String = "Cancel",
        secondaryAction: (() -> Void)? = nil
    ) -> CustomAlertPopupModel {
        return CustomAlertPopupModel(
            title: title,
            alertType: .warning,
            content: {
                Text(message)
                    .multilineTextAlignment(messageAlignment)
                    .padding()
            },
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryAction: secondaryAction
        )
    }

    static func error(
        message: AttributedString,
        messageAlignment: TextAlignment = .center,
        primaryButtonTitle: String = "Ok",
        primaryAction: (() -> Void)? = nil
    ) -> CustomAlertPopupModel {
        return CustomAlertPopupModel(
            title: "Error",
            alertType: .error,
            content: {
                Text(message)
                    .multilineTextAlignment(messageAlignment)
                    .padding()
            },
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction
        )
    }

    static func plain(
        title: String,
        message: AttributedString,
        messageAlignment: TextAlignment = .center,
        primaryButtonTitle: String = "OK",
        primaryAction: (() -> Void)? = nil
    ) -> CustomAlertPopupModel {
        return CustomAlertPopupModel(
            title: "ActionRequired",
            alertType: .none,
            content: {
                Text(message)
                    .multilineTextAlignment(messageAlignment)
                    .padding()
            },
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction
        )
    }
    
    static func info(
        title: AttributedString = AttributedString("Action Required"),
        message: AttributedString,
        messageAlignment: TextAlignment = .center,
        primaryButtonTitle: String = "Continue",
        primaryAction: (() -> Void)? = nil,
        secondaryButtonTitle: String? = "Cancel",
        secondaryAction: (() -> Void)? = nil
    ) -> CustomAlertPopupModel {
        return CustomAlertPopupModel(
            title: title,
            alertType: .info,
            content: {
                Text(message)
                    .multilineTextAlignment(messageAlignment)
                    .padding()
            },
            primaryButtonTitle: primaryButtonTitle,
            primaryAction: primaryAction,
            secondaryButtonTitle: secondaryButtonTitle,
            secondaryAction: secondaryAction
        )
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CustomAlertPopupView(model: .success(message: "Your operation was successful!"))
            CustomAlertPopupView(model: .warning(message: "Are you sure?"))
            CustomAlertPopupView(model: .error(message: "Something went wrong."))
            CustomAlertPopupView(model: .plain(title: "Notice", message: "This is a plain message."))
            CustomAlertPopupView(model: .info(message: "This is an info message."))
        }
    }
}

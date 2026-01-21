//
//  ToastView.swift
//  SwiftUIUtilities
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import SwiftUI

public struct ToastView: View {
  
    var style: ToastStyle
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    public init(
        style: ToastStyle,
        message: String,
        width: CGFloat = .infinity,
        onCancelTapped: @escaping () -> Void
    ) {
        self.style = style
        self.message = message
        self.width = width
        self.onCancelTapped = onCancelTapped
    }
  
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)
            Text(message)
                .font(.caption)
                .foregroundColor(SwiftUI.Color("toastForeground"))
      
            Spacer(minLength: 10)
      
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(style.themeColor)
            }
        }
        .padding()
        .frame(minWidth: 0, maxWidth: width)
        .background(SwiftUI.Color("toastBackground"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(style.themeColor, lineWidth: 1)
                .opacity(0.6)
        )
        .padding(.horizontal, 16)
    }
}

#Preview("Light Mode") {
    VStack(spacing: 32) {
        ToastView(style: .success, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .info, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .warning, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .error, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
    }
}

#Preview("Dark Mode") {
    VStack(spacing: 32) {
        ToastView(style: .success, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .info, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .warning, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
        ToastView(style: .error, message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.") {}
    }
    .preferredColorScheme(.dark)
}

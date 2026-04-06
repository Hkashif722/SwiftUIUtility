//
//  HighlightButtonStyle.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 05/04/26.
//


//
//  ButtonViewModifiers.swift
//

import SwiftUI

public struct HighlightButtonStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accentColor.opacity(0.4) : Color.clear.opacity(0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
}

public struct PressableButtonStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

public enum ButtonStyleOption {
    case press, highlight, plain
}

public extension View {
    
    @ViewBuilder
    func anyButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .press:
            self.pressableButton(action: action)
        case .highlight:
            self.highlightButton(action: action)
        case .plain:
            self.plainButton(action: action)
        }
    }
}

// MARK: - Private Helpers
private extension View {
    
    func highlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
                .contentShape(Rectangle())
        }
        .buttonStyle(HighlightButtonStyle())
    }
    
    func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

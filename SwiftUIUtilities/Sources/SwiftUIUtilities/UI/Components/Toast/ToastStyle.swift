//
//  ToastStyle.swift
//  SwiftUIUtilities
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import Foundation
import SwiftUI

public enum ToastStyle {
    case error
    case warning
    case success
    case info
}

public extension ToastStyle {
    var themeColor: SwiftUI.Color {
        switch self {
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        case .success: return .green
        }
    }
  
    var iconFileName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

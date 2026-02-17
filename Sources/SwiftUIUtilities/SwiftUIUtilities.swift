//
//  SwiftUIUtilities.swift
//  SwiftUIUtilities
//
//  Created by Package on 13/01/26.
//

import Foundation
import SwiftUI

// Re-export dependencies so users don't need to import them separately
@_exported import SwiftfulRouting
@_exported import SwiftfulLoadingIndicators

// MARK: - Module Documentation

/// # SwiftUIUtilities
///
/// A comprehensive Swift Package Manager library providing reusable SwiftUI components,
/// utilities, and patterns for iOS app development.
///
/// ## Key Features:
/// - UI Components (Toast, Alerts, Shimmer)
/// - Navigation System
/// - State Management
/// - Network Utilities
/// - View Modifiers & Extensions
///
/// ## Basic Usage:
///
/// ```swift
/// import SwiftUIUtilities
///
/// struct MyView: View {
///     @State private var toast: Toast?
///
///     var body: some View {
///         Button("Show Toast") {
///             toast = Toast(style: .success, message: "Hello!")
///         }
///         .toastView(toast: $toast)
///     }
/// }
/// ```
///
/// For detailed documentation, see:
/// - README.md for overview
/// - QUICKSTART.md for getting started
/// - EXAMPLES.md for usage examples
/// - PACKAGE_STRUCTURE.md for architecture
///
public enum SwiftUIUtilitiesModule {
    /// Current version of the SwiftUIUtilities package
    public static let version = "1.0.0"
    
    /// Package name
    public static let name = "SwiftUIUtilities"
    
    /// Initialize the package (register fonts, start services, etc.)
    public static func initialize() {
        // Register custom fonts
        FontRegistrar.registerAllFonts()
        
        // Start network monitoring
        ApiReachabilityManager.shared.startMonitoring()
        
        print("✅ SwiftUIUtilities v\(version) initialized")
    }
}

public struct SwiftUtilityEnvironment: Sendable {
    nonisolated(unsafe) internal static var encryptionDecryptionKey: String = {
        fatalError("SwiftUtilityEnvironment.encryptionDecryptionKey must be set before use")
    }()

    public static func configure(encryptionDecryptionKey: String) {
        Self.encryptionDecryptionKey = encryptionDecryptionKey
    }
}



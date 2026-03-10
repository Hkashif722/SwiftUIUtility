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


public struct SwiftUtilityConfig: Sendable {
    public let encryptionDecryptionKey: String
    public let isBlobEnabled: Bool
    public let orgCode: String
    public let configurableDate: String
    public let baseURL: String
    public let lxpOPath: String
    public let lxpBlobPath: String
    public let lxpBlobPath1: String

    public init(
        encryptionDecryptionKey: String,
        isBlobEnabled: Bool,
        orgCode: String,
        configurableDate: String,
        baseURL: String,
        lxpOPath: String,
        lxpBlobPath: String,
        lxpBlobPath1: String
    ) {
        self.encryptionDecryptionKey = encryptionDecryptionKey
        self.isBlobEnabled = isBlobEnabled
        self.orgCode = orgCode
        self.configurableDate = configurableDate
        self.baseURL = baseURL
        self.lxpOPath = lxpOPath
        self.lxpBlobPath = lxpBlobPath
        self.lxpBlobPath1 = lxpBlobPath1
    }
}

public struct SwiftUtilityEnvironment: Sendable {

    nonisolated(unsafe) private static var _shared: SwiftUtilityEnvironment?

    public static var shared: SwiftUtilityEnvironment {
        guard let instance = _shared else {
            fatalError("⚠️ SwiftUtilityEnvironment.configure() must be called before use.")
        }
        return instance
    }

    internal let config: SwiftUtilityConfig

    private init(config: SwiftUtilityConfig) {
        self.config = config
    }

    public static func configure(_ config: SwiftUtilityConfig) {
        _shared = SwiftUtilityEnvironment(config: config)
        APIConst.baseURL = config.baseURL
        APIConst.lxpOPath = config.lxpOPath
        APIConst.lxpBlobPath = config.lxpBlobPath
        APIConst.lxpBlobPath1 = config.lxpBlobPath1
    }
}

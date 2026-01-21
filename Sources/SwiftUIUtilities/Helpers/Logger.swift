//
//  Logger.swift
//  SwiftUIUtilities
//
//  Created by Package on 13/01/26.
//

import Foundation

/// Simple logger utility for the package
public final class Logger {
    
    public enum LogLevel {
        case info
        case warning
        case error
        case debug
    }
    
    public static let shared = Logger()
    
    private init() {}
    
    public func log(_ level: LogLevel, message: String, useColor: Bool = false) {
        let prefix: String
        switch level {
        case .info:
            prefix = "ℹ️ INFO"
        case .warning:
            prefix = "⚠️ WARNING"
        case .error:
            prefix = "❌ ERROR"
        case .debug:
            prefix = "🔍 DEBUG"
        }
        
        print("[\(prefix)] \(message)")
    }
}

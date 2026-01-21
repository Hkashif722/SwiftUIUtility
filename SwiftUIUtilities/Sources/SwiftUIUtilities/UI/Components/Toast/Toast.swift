//
//  Toast.swift
//  SwiftUIUtilities
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import Foundation

public struct Toast: Equatable {
    public var style: ToastStyle
    public var message: String
    public var duration: Double
    public var width: Double
    
    public init(
        style: ToastStyle,
        message: String,
        duration: Double = 3,
        width: Double = .infinity
    ) {
        self.style = style
        self.message = message
        self.duration = duration
        self.width = width
    }
}

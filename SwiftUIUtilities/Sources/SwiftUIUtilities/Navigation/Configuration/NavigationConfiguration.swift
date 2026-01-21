//
//  NavigationConfiguration.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 20/01/26.
//

import SwiftUI

// MARK: - Navigation Configuration
public struct NavigationConfiguration {
    let dynamicTypeSize: DynamicTypeSize
    let modalBackgroundColor: Color
    let modalAnimation: Animation
    let defaultModalID: String
    
    public static let `default` = NavigationConfiguration(
        dynamicTypeSize: .medium,
        modalBackgroundColor: .gray.opacity(0.4),
        modalAnimation: .easeInOut,
        defaultModalID: "default_modal"
    )
}

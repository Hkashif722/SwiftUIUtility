//
//  NavigationViewModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation

public struct NavigationViewModel {
    
    public struct AlertViewModel {
        public var title: String?
        public let message: String
        
        public var okAction: (() -> Void)? = nil
        public var cancelAction: (() -> Void)? = nil
        
        public init(
            title: String? = nil,
            message: String,
            okAction: (() -> Void)? = nil,
            cancelAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.message = message
            self.okAction = okAction
            self.cancelAction = cancelAction
        }
    }
}

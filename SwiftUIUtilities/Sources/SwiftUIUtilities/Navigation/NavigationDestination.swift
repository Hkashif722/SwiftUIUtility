//
//  NavigationDestination.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 20/01/26.
//

import SwiftUI

// MARK: - Navigation Destination
@MainActor
public enum NavigationDestination: NavigationProtocol {
    
    case customAlertPopupView(CustomAlertPopupModel)
    case emptyView

    // MARK: - Navigation Logic
    public func navigate(using router: AnyRouter) {
        switch self {
        case .customAlertPopupView(let customAlertPopupModel):
            showModelViewWithoutDismissBackground(router) {
                CustomAlertPopupView(model: customAlertPopupModel)
            }
            
        case .emptyView:
            pushScreen(router) { router in
                EmptyView()
            }
        }
    }
}

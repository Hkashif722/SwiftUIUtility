//
//  NavigationService.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 20/09/24.
//

import SwiftUI
import Combine
import SwiftfulRouting

@MainActor
public final class NavigationService {
    
    public static let shared = NavigationService()

    private init() {}

    public func navigate(using router: AnyRouter, to destination: NavigationDestination) {
        destination.navigate(using: router)
    }
    
    public func navigate<Destination: NavigationProtocol>(using router: AnyRouter,to destination: Destination) {
        destination.navigate(using: router)
    }
    
    public func dismissScreen(using router: AnyRouter) {
        router.dismissScreen()
    }
    
    public func dismissModal(using router: AnyRouter) {
        router.dismissModal()
    }

    public func dismissEnvironment(using router: AnyRouter) {
        router.dismissEnvironment()
    }

    public func dismissNavigationStack(using router: AnyRouter) {
        if #available(iOS 16, *) {
            router.dismissScreenStack()
        } else {
            router.dismissEnvironment()
        }
    }
}

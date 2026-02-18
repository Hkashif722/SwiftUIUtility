//
//  NavigationDestinationEnum.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 14/12/24.
//

import SwiftUI
import SwiftfulRouting

// MARK: - Navigation Protocol
@MainActor
public protocol NavigationProtocol {
    var configuration: NavigationConfiguration { get }
    
    func navigate(using router: AnyRouter)
    
    func pushScreen<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T)
    func pushFullScreenCover<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T)
    func showResizableSheet<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T)
    func showFullSheetWithDragGesture<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T)
    func showSheetView<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T)
    func showModelViewWithTransition<T: View>(_ router: AnyRouter, view: @escaping () -> T)
    func showModelView<T: View>(_ router: AnyRouter, view: @escaping () -> T)
    func showModelViewWithoutDismissBackground<T: View>(_ router: AnyRouter, view: @escaping () -> T)
    func showAlert(_ router: AnyRouter, alertModel: NavigationViewModel.AlertViewModel)
}

// MARK: - Default Implementation
public extension NavigationProtocol {
    
    var configuration: NavigationConfiguration { .default }
    
    func pushScreen<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T) {
        router.showScreen(.push) { router in
            view(router).dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }

    func pushFullScreenCover<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T) {
        router.showScreen(.fullScreenCover) { router in
            view(router).dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }
    
    func showResizableSheet<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T) {
        if #available(iOS 16, *) {
            router.showResizableSheet(
                sheetDetents: [.medium, .large],
                selection: nil,
                showDragIndicator: true
            ) { router in
                view(router).dynamicTypeSize(configuration.dynamicTypeSize)
            }
        } else {
            router.showScreen(.sheet) { router in
                view(router).dynamicTypeSize(configuration.dynamicTypeSize)
            }
        }
    }


    func showFullSheetWithDragGesture<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T) {
        if #available(iOS 16, *) {
            router.showResizableSheet(
                sheetDetents: [.large],
                selection: nil,
                showDragIndicator: true
            ) { router in
                view(router).dynamicTypeSize(configuration.dynamicTypeSize)
            }
        } else {
            router.showScreen(.sheet) { router in
                view(router).dynamicTypeSize(configuration.dynamicTypeSize)
            }
        }
    }
    
    func showSheetView<T: View>(_ router: AnyRouter, view: @escaping (AnyRouter) -> T) {
        router.showScreen(.sheet) { router in
            view(router).dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }
    
    func showModelViewWithTransition<T: View>(_ router: AnyRouter, view: @escaping () -> T) {
        router.showModal(
            id: configuration.defaultModalID,
            transition: .move(edge: .top),
            animation: configuration.modalAnimation,
            backgroundColor: configuration.modalBackgroundColor
        ) {
            view().dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }
    
    func showModelView<T: View>(_ router: AnyRouter, view: @escaping () -> T) {
        router.showModal(
            id: configuration.defaultModalID,
            animation: configuration.modalAnimation,
            backgroundColor: configuration.modalBackgroundColor
        ) {
            view().dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }
    
    func showModelViewWithoutDismissBackground<T: View>(_ router: AnyRouter, view: @escaping () -> T) {
        router.showModal(
            id: configuration.defaultModalID,
            animation: configuration.modalAnimation,
            backgroundColor: configuration.modalBackgroundColor,
            dismissOnBackgroundTap: false
        ) {
            view().dynamicTypeSize(configuration.dynamicTypeSize)
        }
    }

    func showAlert(_ router: AnyRouter, alertModel: NavigationViewModel.AlertViewModel) {
        router.showAlert(
            .alert,
            title: alertModel.title ?? "",
            subtitle: alertModel.message
        ) {
            if let okAction = alertModel.okAction {
                Button("OK", action: okAction)
            }
            if let cancelAction = alertModel.cancelAction {
                Button("Cancel", action: cancelAction)
            }
        }
    }
}

//
//  RoutableViewProtocol.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 14/12/24.
//

import Foundation
import Combine
import SwiftfulRouting

@MainActor
public protocol RouterProtocol {
    var router: AnyRouter { get }
}

public protocol RoutableViewProtocol: RequestHandlerProtocol {
    func goBack() async
    func dismissEnvironment() async
    func dismissNavigationStack() async
    func dismissModal() async
}

public extension RoutableViewProtocol {
    @MainActor func goBack() {
        NavigationService.shared.dismissScreen(using: router)
    }

    @MainActor func dismissEnvironment() {
        NavigationService.shared.dismissEnvironment(using: router)
    }
    
    @MainActor func dismissNavigationStack() {
        NavigationService.shared.dismissNavigationStack(using: router)
    }
    
    @MainActor func dismissModal() {
        NavigationService.shared.dismissModal(using: router)
    }
}

// MARK: - Request Handler Protocol
@MainActor
public protocol RequestHandlerProtocol: RouterProtocol, ObservableObject {
    var loadingState: LoadingState { get set }
    var emptyState: EmptyStateData { get set }
    var toast: Toast? { get set }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>)
    func manageAlert(_ model: CustomAlertPopupModel)
    func handleRequestError(message: String, logMessage: String)
    func handleAPIError(_ error: Error, resetLoadingState: Bool, showToast: Bool)
}

public extension RequestHandlerProtocol {
    
    var toast: Toast? {
        get { nil }
        set { }
    }
    
    func handleOutput<T>(_ output: T) {
        // Default implementation
    }
    
    func manageAlert(_ model: CustomAlertPopupModel) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            NavigationService.shared.navigate(using: self.router, to: .customAlertPopupView(model))
        }
    }
    
    func handleRequestError(message: String, logMessage: String) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.manageAlert(.error(
                message: AttributedString(message),
                primaryAction: nil
            ))
            Logger.shared.log(.error, message: logMessage)
        }
    }

    func handleAPIError(_ error: Error, resetLoadingState: Bool = true, showToast: Bool = false) {
        if resetLoadingState {
            loadingState = .none
        }
        
        guard ApiReachabilityManager.shared.currentNetworkStatus ?? true else {
            let message = "NoInternet_Msg".localized
            displayError(message: message, showToast: showToast)
            Logger.shared.log(.error, message: "Network unavailable: \(error.localizedDescription)")
            return
        }
        
        let message: String
        let logMessage: String
        
        if let apiError = error as? APIError {
            message = mapAPIErrorToMessage(apiError)
            logMessage = "API Error: \(apiError) - \(apiError.localizedDescription)"
        } else {
            message = "GenericError_Msg".localized
            logMessage = "Unexpected error: \(error.localizedDescription)"
        }
        
        displayError(message: message, showToast: showToast)
        Logger.shared.log(.error, message: logMessage)
    }

    private func displayError(message: String, showToast: Bool) {
        if showToast {
            self.toast = Toast(style: .error, message: message)
        } else {
            manageAlert(.error(
                message: AttributedString(message),
                primaryAction: { self.router.dismissModal() }
            ))
        }
    }

    private func mapAPIErrorToMessage(_ error: APIError) -> String {
        switch error {
        case .unauthorized:
            return "lockedAccount".localized
        case .badRequest, .resourceGone:
            return error.errorDescription ?? "InvalidCredetial_Msg".localized
        case .noData:
            return "NoData_Msg".localized
        case .noResponse:
            return "NoResponse_Msg".localized
        case .networkError:
            return "NetworkError_Msg".localized
        default:
            return "InvalidCredetial_Msg".localized
        }
    }
    
    func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            self.loadingState = .loaded
        case .failure(let error):
            self.loadingState = .none
            self.emptyState = .noData
            print("Request failed with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Publisher Extension
@MainActor
public extension Publisher where Failure == Error {
    func handleAPICall<T: RequestHandlerProtocol>(
        with handler: T,
        receiveValue: @escaping (Output) -> Void
    ) -> AnyCancellable {
        self.subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { [weak handler] completion in
                handler?.handleCompletion(completion)
            } receiveValue: { value in
                receiveValue(value)
            }
    }
    
    func handleAPICallSideEffects<T: RequestHandlerProtocol>(
        with handler: T
    ) -> Publishers.HandleEvents<Publishers.ReceiveOn<Publishers.SubscribeOn<Self, DispatchQueue>, DispatchQueue>> {
        return self
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak handler] value in
                handler?.handleOutput(value)
            }, receiveCompletion: { [weak handler] completion in
                handler?.handleCompletion(completion)
            })
    }
}

//
//  RoutableViewModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 14/12/24.
//

import Foundation
import SwiftfulRouting
@preconcurrency import Combine

/// Base class for all ViewModels that need routing and request handling capabilities
open class RoutableViewModel: RoutableViewProtocol {
    
    // MARK: - Router Properties
    private var _router: AnyRouter?
    
    public var router: AnyRouter {
        guard let _router = _router else {
            fatalError("Router not set. Call setRouter() before using navigation methods.")
        }
        return _router
    }
    
    // MARK: - Combine Properties
    public var cancellables = Set<AnyCancellable>()
    public var tasks = Set<TaskUtility.AnyCancellableTask>()
    public var activeTasks: [Task<Void, Never>] = []
    public var currentTask: Task<Void, Never>?
    
    // MARK: - Pagination Related Properties
    open var itemsPerPage: Int { 10 }
    @Published public var currentPage: Int = 0
    @Published public var hasMore: Bool = true
    @Published public var isLoadingMore: Bool = false
    
    // MARK: - State Properties
    @Published public var loadingState: LoadingState = .none
    @Published public var emptyState: EmptyStateData = .none
    @Published public var toast: Toast? = nil
    
    // MARK: - Initialization
    public init(router: AnyRouter? = nil) {
        self._router = router
    }
    
    // MARK: - Router Setup
    public func setRouter(_ router: AnyRouter) {
        self._router = router
    }
    
    // MARK: - Deinitialization
    deinit {
        cancellables.forEach { $0.cancel() }
        activeTasks.forEach { $0.cancel() }
        tasks.forEach { $0.cancel() }
        currentTask?.cancel()
        Logger.shared.log(.info, message: "De-allocated memory for \(type(of: self))", useColor: true)
    }
}

// MARK: - Network Availability
public extension RoutableViewModel {
    
    func checkNetworkAvailability() -> Bool {
        let isNetworkAvailable: Bool = ApiReachabilityManager.shared.currentNetworkStatus ?? false
        
        if !isNetworkAvailable {
            self.showNoInternetAlert()
        }
        
        return isNetworkAvailable
    }
    
    @MainActor
    private func showNoInternetAlert() {
        let popupModel: CustomAlertPopupModel = .info(
            title: AttributedString("No Internet Connection"),
            message: AttributedString("No internet connection. Switching to offline mode."),
            messageAlignment: .leading,
            primaryButtonTitle: "Ok_Title".localized,
            primaryAction: { [weak self] in
                guard let _ = self else { return }
                Task { @MainActor in
                    // Handle offline mode
                }
            },
            secondaryButtonTitle: nil
        )
        
        NavigationService.shared.navigate(using: router, to: NavigationDestination.customAlertPopupView(popupModel))
    }
}

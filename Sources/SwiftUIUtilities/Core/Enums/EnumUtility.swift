//
//  EnumUtility.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation
import SwiftUI
import SwiftfulLoadingIndicators

// MARK: - Empty State Data
public enum EmptyStateData {
    case noData
    case error
    case noConnection
    case search
    case none
    
    public var content: (icon: Image, gifName: String?, title: String?, label: String?, actionButton: AnyView?) {
        switch self {
        case .noData:
            return (
                icon: Image(systemName: "exclamationmark.triangle"),
                gifName: "swg",
                title: NSLocalizedString("empty_state_no_data_title".localized, comment: ""),
                label: NSLocalizedString("empty_state_no_data_label".localized, comment: ""),
                actionButton: nil
            )
        case .error:
            return (
                icon: Image(systemName: "xmark.octagon"),
                gifName: "error",
                title: NSLocalizedString("empty_state_error_title".localized, comment: ""),
                label: NSLocalizedString("empty_state_error_label".localized, comment: ""),
                actionButton: nil
            )
        case .noConnection:
            return (
                icon: Image(systemName: "wifi.slash"),
                gifName: "no_network",
                title: NSLocalizedString("empty_state_no_connection_title".localized, comment: ""),
                label: NSLocalizedString("empty_state_no_connection_label".localized, comment: ""),
                actionButton: AnyView(Button(NSLocalizedString("empty_state_retry_button".localized, comment: "")) {
                    print("Retry tapped")
                })
            )
        case .search:
            return (
                icon: Image(systemName: "magnifyingglass"),
                gifName: nil,
                title: nil,
                label: NSLocalizedString("empty_state_search_label".localized, comment: ""),
                actionButton: nil
            )
        case .none:
            return (
                icon: Image(systemName: "magnifyingglass"),
                gifName: nil,
                title: nil,
                label: NSLocalizedString("empty_state_checking_label".localized, comment: ""),
                actionButton: nil
            )
        }
    }
}

// MARK: - Loading State
public enum LoadingState: Equatable {
    case loading(title: String? = nil, message: String, indicator: LoadingIndicator.LoadingAnimation? = nil)
    case progressLoading(progress: CGFloat, title: String? = nil, message: String, indicator: LoadingIndicator.LoadingAnimation? = nil)
    case none
    case loaded

    public var title: String {
        switch self {
        case .loading(let title, _, _), .progressLoading(_, let title, _, _):
            return title ?? "loadingLbl".localized
        case .none, .loaded:
            return ""
        }
    }

    public var message: String {
        switch self {
        case .loading(_, let message, _), .progressLoading(_, _, let message, _):
            return message
        case .none, .loaded:
            return ""
        }
    }

    public var progress: CGFloat {
        switch self {
        case .progressLoading(let progress, _, _, _):
            return progress
        default:
            return 0.0
        }
    }

    public var indicator: LoadingIndicator.LoadingAnimation? {
        switch self {
        case .loading(_, _, let indicator), .progressLoading(_, _, _, let indicator):
            return indicator
        case .none, .loaded:
            return nil
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading, .progressLoading:
            return true
        case .none, .loaded:
            return false
        }
    }
}

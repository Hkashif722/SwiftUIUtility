//
//  PaginatableViewModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation
import Combine

// MARK: - Paginatable Protocol
@MainActor
public protocol PaginatableViewModel: AnyObject, ObservableObject {
    associatedtype Item: Identifiable
    
    var items: [Item] { get set }
    var currentPage: Int { get set }
    var hasMore: Bool { get set }
    var isLoadingMore: Bool { get set }
    var loadingState: LoadingState { get set }
    var emptyState: EmptyStateData { get set }
    var itemsPerPage: Int { get }
    
    func fetchItems(pageIndex: Int, isLoadingMore: Bool) async throws -> [Item]
    func setLoadingState(isLoadingMore: Bool)
    func handleFetchError(_ error: Error, isLoadingMore: Bool)
}

// MARK: - Default Implementations
public extension PaginatableViewModel {
    
    var itemsPerPage: Int { 10 }
    
    /// Load initial page of items
    func loadInitial() async {
        currentPage = 1
        items.removeAll()
        hasMore = true
        isLoadingMore = false
        await performFetch(isLoadingMore: false)
    }
    
    /// Load next page of items
    func loadMore() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        currentPage += 1
        await performFetch(isLoadingMore: true)
    }
    
    /// Refresh - reload from first page
    func refresh() async {
        await loadInitial()
    }
    
    /// Reset all pagination state
    func reset() {
        items.removeAll()
        currentPage = 0
        hasMore = true
        isLoadingMore = false
        loadingState = .none
        emptyState = .none
    }
    
    /// Check if should trigger load more for current item
    func shouldLoadMore(currentItem: Item) -> Bool {
        guard let lastItem = items.last else { return false }
        return currentItem.id == lastItem.id && hasMore && !isLoadingMore
    }
    
    /// Internal fetch logic
    private func performFetch(isLoadingMore: Bool) async {
        // Set appropriate loading state
        setLoadingState(isLoadingMore: isLoadingMore)
        
        do {
            let newItems = try await fetchItems(pageIndex: currentPage, isLoadingMore: isLoadingMore)
            
            // Append or replace items based on load type
            if isLoadingMore {
                items.append(contentsOf: newItems)
            } else {
                items = newItems
            }
            
            // Update pagination state
            hasMore = newItems.count >= itemsPerPage
            
            // Clear loading state and set empty state if needed
            if !isLoadingMore {
                loadingState = .loaded
                emptyState = items.isEmpty ? .noData : .none
            }
            
            // Always reset isLoadingMore flag
            self.isLoadingMore = false
            
        } catch {
            // Rollback page on error
            if isLoadingMore {
                currentPage -= 1
            }
            
            // Reset loading flag
            self.isLoadingMore = false
            
            // Handle error
            handleFetchError(error, isLoadingMore: isLoadingMore)
        }
    }
    
    /// Default implementation - can be overridden
    func setLoadingState(isLoadingMore: Bool) {
        if !isLoadingMore {
            // Initial load - show full loading state
            self.loadingState = .loading(title: "Fetching records...", message: "Please wait.")
            self.emptyState = .none
        }
        // For load more, we don't change loadingState - use isLoadingMore flag instead
    }
    
    /// Default implementation - can be overridden
    func handleFetchError(_ error: Error, isLoadingMore: Bool) {
        if !isLoadingMore {
            // Initial load error - set error state
            self.loadingState = .none
            self.emptyState = .error
        }
        // For load more errors, just log - don't change states
        Logger.shared.log(.error, message: "Fetch error: \(error.localizedDescription)")
    }
}

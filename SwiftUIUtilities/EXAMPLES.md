# SwiftUIUtilities - Usage Examples

This document provides detailed examples of how to use various components from the SwiftUIUtilities package.

## Table of Contents
1. [Toast Notifications](#toast-notifications)
2. [Custom Alerts](#custom-alerts)
3. [Shimmer Effects](#shimmer-effects)
4. [Navigation](#navigation)
5. [View Models](#view-models)
6. [Pagination](#pagination)
7. [Network Monitoring](#network-monitoring)
8. [View Modifiers](#view-modifiers)

## Toast Notifications

### Basic Toast Usage

```swift
import SwiftUI
import SwiftUIUtilities

struct ContentView: View {
    @State private var toast: Toast?
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show Success Toast") {
                toast = Toast(style: .success, message: "Operation completed!")
            }
            
            Button("Show Error Toast") {
                toast = Toast(style: .error, message: "Something went wrong!")
            }
            
            Button("Show Warning Toast") {
                toast = Toast(style: .warning, message: "Please be careful!")
            }
            
            Button("Show Info Toast") {
                toast = Toast(style: .info, message: "Here's some information.")
            }
        }
        .toastView(toast: $toast)
    }
}
```

### Custom Duration Toast

```swift
toast = Toast(
    style: .success,
    message: "This will show for 5 seconds",
    duration: 5.0
)
```

## Custom Alerts

### Success Alert

```swift
let successAlert = CustomAlertPopupModel.success(
    message: AttributedString("Your data has been saved successfully!"),
    primaryAction: {
        print("OK tapped")
    }
)

NavigationService.shared.navigate(
    using: router,
    to: .customAlertPopupView(successAlert)
)
```

### Warning Alert with Actions

```swift
let warningAlert = CustomAlertPopupModel.warning(
    title: AttributedString("Delete Item?"),
    message: AttributedString("This action cannot be undone."),
    primaryAction: {
        // Perform deletion
        deleteItem()
    },
    secondaryAction: {
        // Cancel action
        print("Cancelled")
    }
)

NavigationService.shared.navigate(
    using: router,
    to: .customAlertPopupView(warningAlert)
)
```

### Error Alert

```swift
let errorAlert = CustomAlertPopupModel.error(
    message: AttributedString("Failed to load data. Please try again."),
    primaryAction: {
        retryLoading()
    }
)
```

### Custom Alert with Info

```swift
let infoAlert = CustomAlertPopupModel.info(
    title: AttributedString("Update Available"),
    message: AttributedString("A new version is available. Would you like to update now?"),
    primaryButtonTitle: "Update",
    primaryAction: {
        performUpdate()
    },
    secondaryButtonTitle: "Later"
)
```

## Shimmer Effects

### Basic Shimmer

```swift
struct LoadingCard: View {
    var body: some View {
        VStack(spacing: 10) {
            ShimmerView()
                .frame(height: 200)
                .cornerRadius(12)
            
            ShimmerView()
                .frame(height: 20)
                .cornerRadius(4)
            
            ShimmerView()
                .frame(width: 150, height: 20)
                .cornerRadius(4)
        }
        .padding()
    }
}
```

### Profile Loading Shimmer

```swift
struct ProfileLoadingView: View {
    var body: some View {
        HStack(spacing: 15) {
            ShimmerView()
                .frame(width: 60, height: 60)
                .cornerRadius(30)
            
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView()
                    .frame(width: 120, height: 16)
                    .cornerRadius(4)
                
                ShimmerView()
                    .frame(width: 80, height: 14)
                    .cornerRadius(4)
            }
        }
        .padding()
    }
}
```

## Navigation

### Setting Up Navigation in Your App

```swift
import SwiftUI
import SwiftfulRouting
import SwiftUIUtilities

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                MainView()
            }
        }
    }
}
```

### Using NavigationService

```swift
struct ProfileView: View {
    @Environment(\.router) var router
    
    func logout() {
        let alert = CustomAlertPopupModel.warning(
            title: AttributedString("Logout"),
            message: AttributedString("Are you sure you want to logout?"),
            primaryAction: {
                // Perform logout
                NavigationService.shared.dismissEnvironment(using: router)
            }
        )
        
        NavigationService.shared.navigate(
            using: router,
            to: .customAlertPopupView(alert)
        )
    }
}
```

## View Models

### Creating a Routable ViewModel

```swift
import SwiftUIUtilities
import Combine

class UserProfileViewModel: RoutableViewModel {
    @Published var user: User?
    @Published var isEditing: Bool = false
    
    func loadUserProfile(userId: String) async {
        loadingState = .loading(message: "Loading profile...")
        
        do {
            let userData = try await apiService.fetchUser(id: userId)
            self.user = userData
            loadingState = .loaded
            emptyState = .none
        } catch {
            handleAPIError(error, showToast: true)
            emptyState = .error
        }
    }
    
    func updateProfile(_ updatedUser: User) async {
        loadingState = .loading(message: "Updating profile...")
        
        do {
            try await apiService.updateUser(updatedUser)
            self.user = updatedUser
            loadingState = .loaded
            
            toast = Toast(
                style: .success,
                message: "Profile updated successfully!"
            )
        } catch {
            handleAPIError(error, showToast: true)
        }
    }
}
```

### Using the ViewModel in a View

```swift
struct UserProfileView: View {
    @StateObject private var viewModel: UserProfileViewModel
    @Environment(\.router) var router
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: UserProfileViewModel())
    }
    
    var body: some View {
        contentView
            .onAppear {
                viewModel.setRouter(router)
                Task {
                    await viewModel.loadUserProfile(userId: userId)
                }
            }
            .toastView(toast: $viewModel.toast)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.loadingState {
        case .loading:
            ProgressView("Loading...")
        case .loaded:
            if let user = viewModel.user {
                ProfileDetailsView(user: user)
            }
        default:
            EmptyView()
        }
    }
}
```

## Pagination

### Creating a Paginated List ViewModel

```swift
import SwiftUIUtilities

struct Article: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
}

class ArticlesViewModel: RoutableViewModel, PaginatableViewModel {
    typealias Item = Article
    
    @Published var items: [Article] = []
    
    override var itemsPerPage: Int { 20 }
    
    func fetchItems(pageIndex: Int, isLoadingMore: Bool) async throws -> [Article] {
        return try await apiService.fetchArticles(page: pageIndex, limit: itemsPerPage)
    }
    
    override func setLoadingState(isLoadingMore: Bool) {
        if !isLoadingMore {
            loadingState = .loading(message: "Loading articles...")
        }
    }
    
    override func handleFetchError(_ error: Error, isLoadingMore: Bool) {
        loadingState = .none
        if !isLoadingMore {
            emptyState = .noData
        }
        handleAPIError(error, showToast: isLoadingMore)
    }
}
```

### Using the Paginated ViewModel

```swift
struct ArticlesListView: View {
    @StateObject private var viewModel = ArticlesViewModel()
    @Environment(\.router) var router
    
    var body: some View {
        List {
            ForEach(viewModel.items) { article in
                ArticleRow(article: article)
                    .onAppear {
                        if viewModel.shouldLoadMore(currentItem: article) {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.setRouter(router)
        }
        .task {
            await viewModel.loadInitial()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toastView(toast: $viewModel.toast)
    }
}
```

## Network Monitoring

### Monitoring Network Status

```swift
import SwiftUIUtilities

struct NetworkStatusBanner: View {
    @State private var isConnected: Bool = true
    
    var body: some View {
        VStack {
            if !isConnected {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("No Internet Connection")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
            }
        }
        .onAppear {
            isConnected = ApiReachabilityManager.shared.isNetworkAvailable
        }
        .onReceive(NotificationCenter.default.publisher(
            for: ApiReachabilityManager.networkStatusChanged
        )) { notification in
            if let connected = notification.userInfo?["isConnected"] as? Bool {
                withAnimation {
                    isConnected = connected
                }
            }
        }
    }
}
```

### Checking Network Before API Call

```swift
func performNetworkOperation() async {
    guard checkNetworkAvailability() else {
        return // Network alert is shown automatically
    }
    
    // Proceed with network operation
    do {
        let data = try await apiService.fetchData()
        // Handle data
    } catch {
        handleAPIError(error)
    }
}
```

## View Modifiers

### Card Style Modifier

```swift
Text("Card Content")
    .cardStyle(
        backgroundColor: .white,
        cornerRadius: 12,
        shadowColor: .black.opacity(0.1),
        shadowRadius: 8,
        padding: 20
    )
```

### Gradient Border

```swift
Rectangle()
    .fill(Color.white)
    .frame(height: 100)
    .gradientBorder(
        cornerRadius: 20,
        lineWidth: 2,
        colors: [.blue, .purple, .pink]
    )
```

### Dynamic Text Color

```swift
let backgroundColor = Color.blue

Text("Dynamic Text")
    .padding()
    .background(backgroundColor)
    .dynamicTextColor(for: backgroundColor)
```

### State-Driven View

```swift
contentView
    .stateDrivenView(
        loadingState: viewModel.loadingState,
        emptyState: viewModel.emptyState,
        loadingContent: {
            ProgressView("Loading...")
        },
        emptyContent: { state in
            CustomViewModifier.EmptyStateView(
                icon: state.content.icon,
                gifName: state.content.gifName,
                title: state.content.title,
                label: state.content.label,
                actionButton: state.content.actionButton
            )
        }
    )
```

### Custom Back Button

```swift
NavigationView {
    ContentView()
        .customBackButton(
            title: "Back",
            navTitle: "My Screen",
            navTitileImage: "star.fill"
        ) {
            // Custom back action
            print("Custom back button tapped")
        }
}
```

## Best Practices

1. **Always set the router** in your view models before navigating
2. **Handle errors gracefully** using the built-in error handling protocols
3. **Use pagination** for large data sets to improve performance
4. **Monitor network status** for better user experience
5. **Leverage view modifiers** for consistent styling across your app
6. **Use toast for non-critical notifications** and alerts for important actions
7. **Implement proper loading states** to give users feedback

## Common Patterns

### Loading → Success → Toast Pattern

```swift
func saveData() async {
    loadingState = .loading(message: "Saving...")
    
    do {
        try await apiService.save(data)
        loadingState = .loaded
        toast = Toast(style: .success, message: "Saved successfully!")
    } catch {
        handleAPIError(error, showToast: true)
    }
}
```

### Pull-to-Refresh Pattern

```swift
List(items) { item in
    ItemRow(item: item)
}
.refreshable {
    await viewModel.refresh()
}
```

### Infinite Scroll Pattern

```swift
ScrollView {
    LazyVStack {
        ForEach(viewModel.items) { item in
            ItemView(item: item)
                .onAppear {
                    if viewModel.shouldLoadMore(currentItem: item) {
                        Task {
                            await viewModel.loadMore()
                        }
                    }
                }
        }
    }
}
```

# SwiftUIUtilities

A comprehensive Swift Package Manager library providing reusable SwiftUI components, utilities, and patterns for iOS app development.

## Features

### 🎨 UI Components
- **ShimmerView**: Elegant loading skeleton with shimmer animation
- **CustomAlertPopupView**: Customizable alert dialogs with multiple styles
- **Toast System**: Non-intrusive toast notifications with various styles

### 🧭 Navigation
- **NavigationService**: Centralized navigation management
- **RoutableViewProtocol**: Protocol-oriented navigation with view models
- **NavigationDestination**: Type-safe navigation destinations

### 🔄 State Management
- **LoadingState**: Unified loading state management
- **EmptyStateData**: Standardized empty state handling
- **PaginatableViewModel**: Protocol for easy pagination implementation

### 🌐 Networking
- **APIError**: Comprehensive error handling for API calls
- **ApiReachabilityManager**: Network connectivity monitoring
- **RequestHandlerProtocol**: Streamlined API request handling

### 🎨 View Modifiers & Extensions
- Color extensions for dynamic text colors
- String extensions with localization support
- Custom view modifiers for common styling patterns
- Gradient borders, shadows, and animations

## Requirements

- iOS 15.0+
- macOS 12.0+
- Swift 5.9+
- Xcode 14.0+

**Resource Bundle Access:**
This package uses `Bundle.swiftUIUtilitiesModule` for resource access. This custom bundle accessor works in all scenarios:
- ✅ Works with SPM auto-generated `Bundle.module` (when available)
- ✅ Works when `Bundle.module` is not generated
- ✅ No build errors or compiler warnings
- ✅ Compatible with all Swift Package Manager versions

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUIUtilities.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Packages...
2. Enter package URL
3. Select version and add to your target

### One-Time Import Setup (Optional)

**To avoid importing SwiftUIUtilities in every file**, add this to your app's main file or a dedicated imports file:

```swift
@_exported import SwiftUIUtilities
```

This will make all SwiftUIUtilities types available throughout your app without needing to import it in each file.

**Example in your App file:**

```swift
import SwiftUI
@_exported import SwiftUIUtilities  // ← Add this

@main
struct MyApp: App {
    init() {
        // Initialize the package (registers fonts, starts network monitoring)
        SwiftUIUtilitiesModule.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                ContentView()
            }
        }
    }
}
```

**Now you can use it anywhere without imports:**

```swift
// No import needed! ✨
struct MyView: View {
    @State private var toast: Toast?
    
    var body: some View {
        Button("Show") {
            toast = Toast(style: .success, message: "Works!")
        }
        .toastView(toast: $toast)
    }
}
```

### Alternative: Create a Global Imports File

Create a file named `GlobalImports.swift`:

```swift
//
//  GlobalImports.swift
//

@_exported import SwiftUIUtilities
@_exported import SwiftUI
@_exported import Combine
```

Then all types from these modules will be available throughout your project!

## Usage

### Toast Notifications

```swift
import SwiftUIUtilities

struct ContentView: View {
    @State private var toast: Toast?
    
    var body: some View {
        VStack {
            Button("Show Toast") {
                toast = Toast(
                    style: .success,
                    message: "Operation completed successfully!"
                )
            }
        }
        .toastView(toast: $toast)
    }
}
```

### Custom Alerts

```swift
import SwiftUIUtilities

struct MyView: View {
    @EnvironmentObject var router: AnyRouter
    
    func showAlert() {
        let model = CustomAlertPopupModel.warning(
            message: AttributedString("Are you sure?"),
            primaryAction: { print("Confirmed") },
            secondaryAction: { print("Cancelled") }
        )
        
        NavigationService.shared.navigate(
            using: router,
            to: .customAlertPopupView(model)
        )
    }
}
```

### Shimmer Loading

```swift
import SwiftUIUtilities

struct LoadingView: View {
    var body: some View {
        VStack {
            ShimmerView()
                .frame(height: 20)
                .cornerRadius(5)
            
            ShimmerView()
                .frame(height: 100)
                .cornerRadius(10)
        }
        .padding()
    }
}
```

### Routable View Model

```swift
import SwiftUIUtilities
import SwiftfulRouting

class MyViewModel: RoutableViewModel {
    
    func fetchData() async {
        loadingState = .loading(message: "Fetching data...")
        
        do {
            // Your API call here
            let data = try await apiService.fetchData()
            loadingState = .loaded
        } catch {
            handleAPIError(error)
        }
    }
}

struct MyView: View {
    @StateObject private var viewModel: MyViewModel
    @Environment(\.router) var router
    
    init() {
        _viewModel = StateObject(wrappedValue: MyViewModel())
    }
    
    var body: some View {
        VStack {
            // Your content
        }
        .onAppear {
            viewModel.setRouter(router)
        }
        .toastView(toast: $viewModel.toast)
    }
}
```

### Pagination

```swift
import SwiftUIUtilities

class ItemsViewModel: RoutableViewModel, PaginatableViewModel {
    typealias Item = MyItem
    
    @Published var items: [MyItem] = []
    
    func fetchItems(pageIndex: Int, isLoadingMore: Bool) async throws -> [MyItem] {
        // Your API call here
        return try await apiService.fetchItems(page: pageIndex)
    }
}

struct ItemsListView: View {
    @StateObject private var viewModel = ItemsViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
                .onAppear {
                    if viewModel.shouldLoadMore(currentItem: item) {
                        Task {
                            await viewModel.loadMore()
                        }
                    }
                }
        }
        .task {
            await viewModel.loadInitial()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}
```

### Network Monitoring

```swift
import SwiftUIUtilities

struct NetworkStatusView: View {
    @State private var isConnected: Bool = true
    
    var body: some View {
        Text(isConnected ? "Connected" : "Offline")
            .onReceive(NotificationCenter.default.publisher(
                for: ApiReachabilityManager.networkStatusChanged
            )) { notification in
                if let connected = notification.userInfo?["isConnected"] as? Bool {
                    isConnected = connected
                }
            }
    }
}
```

## Package Structure

```
SwiftUIUtilities/
├── Sources/
│   └── SwiftUIUtilities/
│       ├── Core/
│       │   └── Enums/           # Core enumerations
│       ├── Extensions/          # Swift & SwiftUI extensions
│       ├── Helpers/             # Helper classes (Logger, ColorUtility, etc.)
│       ├── Modifiers/           # Custom view modifiers
│       ├── Navigation/          # Navigation system
│       │   └── Models/
│       ├── Network/             # Networking utilities
│       ├── Protocols/           # Protocol definitions
│       ├── Resources/           # Fonts and assets
│       │   └── Fonts/
│       ├── UI/
│       │   ├── Components/      # Reusable UI components
│       │   │   └── Toast/
│       │   └── SwiftUIUtility.swift
│       ├── Utilities/           # General utilities
│       └── ViewModels/          # Base view model classes
└── Tests/
    └── SwiftUIUtilitiesTests/
```

## Dependencies

- [SwiftfulRouting](https://github.com/SwiftfulThinking/SwiftfulRouting) - Navigation management
- [SwiftfulLoadingIndicators](https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators) - Loading animations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT license. See the LICENSE file for more info.

## Author

Kashif Hussain

## Acknowledgments

- Toast system inspired by Ondrej Kvasnovsky
- Built with SwiftUI and modern Swift concurrency

# SwiftUIUtilities - Quick Start Guide

Get up and running with SwiftUIUtilities in under 5 minutes!

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Packages...**
2. Enter the package URL (when published)
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUIUtilities.git", from: "1.0.0")
]
```

### 🎯 Skip Imports Everywhere (Recommended!)

**To avoid writing `import SwiftUIUtilities` in every file**, add this to your App file:

```swift
import SwiftUI
@_exported import SwiftUIUtilities  // ← Magic line!

@main
struct MyApp: App {
    init() {
        SwiftUIUtilitiesModule.initialize()  // Initialize fonts & monitoring
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

**That's it!** Now all SwiftUIUtilities types are available everywhere without imports. ✨

## Initial Setup

### 1. Basic Import (if not using @_exported)

```swift
import SwiftUIUtilities
```

### 2. Setup Navigation (If using routing)

```swift
import SwiftfulRouting

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                ContentView()
            }
        }
    }
}
```

### 3. Register Fonts (Optional)

```swift
@main
struct MyApp: App {
    init() {
        FontRegistrar.registerAllFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Common Use Cases

### 1. Show a Toast Notification

```swift
struct ContentView: View {
    @State private var toast: Toast?
    
    var body: some View {
        Button("Show Toast") {
            toast = Toast(style: .success, message: "Hello!")
        }
        .toastView(toast: $toast)
    }
}
```

### 2. Display a Custom Alert

```swift
struct MyView: View {
    @Environment(\.router) var router
    
    func showAlert() {
        let alert = CustomAlertPopupModel.success(
            message: AttributedString("Success!"),
            primaryAction: { print("OK") }
        )
        
        NavigationService.shared.navigate(
            using: router,
            to: .customAlertPopupView(alert)
        )
    }
    
    var body: some View {
        Button("Show Alert", action: showAlert)
    }
}
```

### 3. Create a Loading Screen with Shimmer

```swift
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 10) {
            ShimmerView()
                .frame(height: 100)
                .cornerRadius(10)
            
            ShimmerView()
                .frame(height: 20)
                .cornerRadius(4)
        }
        .padding()
    }
}
```

### 4. Build a View with ViewModel

```swift
// ViewModel
class MyViewModel: RoutableViewModel {
    func loadData() async {
        loadingState = .loading(message: "Loading...")
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        loadingState = .loaded
        toast = Toast(style: .success, message: "Data loaded!")
    }
}

// View
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
    @Environment(\.router) var router
    
    var body: some View {
        VStack {
            if viewModel.loadingState.isLoading {
                ProgressView()
            } else {
                Text("Content Here")
            }
            
            Button("Load Data") {
                Task { await viewModel.loadData() }
            }
        }
        .onAppear {
            viewModel.setRouter(router)
        }
        .toastView(toast: $viewModel.toast)
    }
}
```

### 5. Implement Pagination

```swift
// Model
struct Item: Identifiable {
    let id: String
    let name: String
}

// ViewModel
class ItemsViewModel: RoutableViewModel, PaginatableViewModel {
    typealias Item = Item
    
    @Published var items: [Item] = []
    
    func fetchItems(pageIndex: Int, isLoadingMore: Bool) async throws -> [Item] {
        // Your API call here
        return [] // Replace with actual data
    }
}

// View
struct ItemsView: View {
    @StateObject private var viewModel = ItemsViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
                .onAppear {
                    if viewModel.shouldLoadMore(currentItem: item) {
                        Task { await viewModel.loadMore() }
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

### 6. Monitor Network Status

```swift
struct NetworkBanner: View {
    @State private var isConnected = true
    
    var body: some View {
        Group {
            if !isConnected {
                Text("No Connection")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
            }
        }
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

## Pro Tips

1. **Always set the router** on your view models in `onAppear`:
   ```swift
   .onAppear { viewModel.setRouter(router) }
   ```

2. **Use toast for success**, alerts for important decisions:
   ```swift
   // Success → Toast
   toast = Toast(style: .success, message: "Saved!")
   
   // Important action → Alert
   let alert = CustomAlertPopupModel.warning(...)
   ```

3. **Combine view modifiers** for powerful effects:
   ```swift
   Text("Hello")
       .cardStyle()
       .gradientBorder()
       .dynamicTextColor(for: .blue)
   ```

4. **Handle API errors automatically**:
   ```swift
   do {
       let data = try await apiCall()
   } catch {
       handleAPIError(error, showToast: true)
   }
   ```

## Next Steps

- Read [EXAMPLES.md](EXAMPLES.md) for detailed examples
- Review [PACKAGE_STRUCTURE.md](PACKAGE_STRUCTURE.md) for architecture details
- Check the inline documentation in the source code
- Explore the test files for usage patterns

## Common Issues

### Router not set error
**Solution**: Call `viewModel.setRouter(router)` in `onAppear`

### Toast not showing
**Solution**: Add `.toastView(toast: $viewModel.toast)` modifier to your view

### Network status not updating
**Solution**: Observe the `networkStatusChanged` notification

### Colors not matching app theme
**Solution**: Customize `ColorUtility` or create your own color scheme

## Need Help?

- 📖 Full documentation: [README.md](README.md)
- 💡 Usage examples: [EXAMPLES.md](EXAMPLES.md)
- 🏗️ Architecture: [PACKAGE_STRUCTURE.md](PACKAGE_STRUCTURE.md)
- 🐛 Issues: File on GitHub

Happy coding! 🚀

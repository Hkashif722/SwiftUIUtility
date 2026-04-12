# How to Skip Import Statements

This guide shows you how to set up SwiftUIUtilities so you never need to write `import SwiftUIUtilities` again!

## Method 1: App File @_exported (Recommended)

The simplest approach - add one line to your App file:

```swift
import SwiftUI
@_exported import SwiftUIUtilities  // ← Add this line

@main
struct MyApp: App {
    init() {
        // Optional: Initialize package features
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

**Done!** Now use SwiftUIUtilities types anywhere:

```swift
// File: SomeRandomView.swift
// No import needed! ✨

struct SomeRandomView: View {
    @State private var toast: Toast?
    
    var body: some View {
        Button("Show Toast") {
            toast = Toast(style: .success, message: "No import needed!")
        }
        .toastView(toast: $toast)
    }
}
```

## Method 2: Global Imports File

Create a dedicated file for all your global imports:

**Step 1:** Create `GlobalImports.swift` in your project:

```swift
//
//  GlobalImports.swift
//  MyApp
//

// Re-export common frameworks
@_exported import SwiftUI
@_exported import Combine
@_exported import SwiftUIUtilities

// Optional: Re-export other packages you use everywhere
// @_exported import Alamofire
// @_exported import SDWebImage
```

**Step 2:** Add it to your target

That's it! Now SwiftUI, Combine, and SwiftUIUtilities are available in every file.

## Method 3: Precompiled Header (Advanced)

For even faster compilation, you can use a bridging header:

**Step 1:** Create `PrefixHeader.pch`:

```objc
#ifdef __OBJC__
@import SwiftUI;
@import Combine;
#endif
```

**Step 2:** Configure in Build Settings:
- Search for "Prefix Header"
- Set path to your `.pch` file

**Step 3:** In your App file:

```swift
@_exported import SwiftUIUtilities
```

## What Gets Exported?

When you use `@_exported import SwiftUIUtilities`, these become available everywhere:

### ✅ All UI Components
- `Toast`, `ToastStyle`, `ToastView`
- `CustomAlertPopupView`, `CustomAlertPopupModel`, `AlertType`
- `ShimmerView`

### ✅ View Modifiers
- `.toastView(toast:)`
- `.cardStyle()`
- `.gradientBorder()`
- `.dynamicTextColor()`
- `.stateDrivenView()`
- And 40+ more...

### ✅ Extensions
- `String.localized`
- `Color.contrastingTextColor()`
- `View.glow()`

### ✅ Base Classes
- `RoutableViewModel`
- `NavigationService`
- `ApiReachabilityManager`

### ✅ Protocols
- `RoutableViewProtocol`
- `PaginatableViewModel`
- `RequestHandlerProtocol`

### ✅ Utilities
- `LoadingState`, `EmptyStateData`
- `APIErrorUtils`
- `SwiftUIUtility` (all components)
- `ColorUtility`
- `Logger`

### ✅ Dependencies (Also Exported!)
- SwiftfulRouting (no need to import separately)
- SwiftfulLoadingIndicators (no need to import separately)

## Benefits

### ✅ Cleaner Code
```swift
// Before
import SwiftUI
import SwiftUIUtilities
import SwiftfulRouting
import Combine

// After  
// Nothing! All already available
```

### ✅ Faster Development
- No more "Type 'Toast' not found" errors
- Autocomplete works immediately
- Less typing

### ✅ Consistent Codebase
- Same imports (or lack thereof) in every file
- New team members can start coding immediately

### ✅ Easy Refactoring
- Move files around without worrying about imports
- Add new files without boilerplate

## Best Practices

### ✅ DO: Use for utilities you use everywhere
```swift
@_exported import SwiftUIUtilities  // Used in most files
@_exported import SwiftUI             // Used in all SwiftUI files
```

### ⚠️ DON'T: Export rarely used packages
```swift
// DON'T do this for packages used in 1-2 files
@_exported import SomeSpecializedLibrary
```

### ✅ DO: Document in your README
Let team members know about your global imports:

```markdown
## Project Setup
This project uses global imports. SwiftUI and SwiftUIUtilities 
are available in all files without import statements.
```

### ✅ DO: Initialize in App
```swift
@main
struct MyApp: App {
    init() {
        SwiftUIUtilitiesModule.initialize()
    }
    // ...
}
```

## Troubleshooting

### "Ambiguous use of..." errors

If you get ambiguous type errors:
1. You might have a naming conflict
2. Explicitly import in that specific file:

```swift
import SwiftUIUtilities  // Make it explicit for this file
```

### Autocomplete not working

1. Clean build folder (⇧⌘K)
2. Rebuild project (⌘B)
3. Restart Xcode

### Circular dependencies

If you get circular dependency warnings:
- Don't use `@_exported` in library modules
- Only use it in your app's main target

## Example Project Structure

```
MyApp/
├── MyApp.swift                    # @_exported import here
├── GlobalImports.swift            # Optional: additional exports
├── Views/
│   ├── HomeView.swift            # No imports needed!
│   ├── ProfileView.swift         # No imports needed!
│   └── SettingsView.swift        # No imports needed!
└── ViewModels/
    ├── HomeViewModel.swift       # No imports needed!
    └── ProfileViewModel.swift    # No imports needed!
```

## Summary

**Add this to your App file:**
```swift
@_exported import SwiftUIUtilities
```

**Then initialize:**
```swift
init() {
    SwiftUIUtilitiesModule.initialize()
}
```

**That's it! Now code anywhere without imports:**
```swift
struct AnyView: View {
    @State var toast: Toast?  // Works!
    
    var body: some View {
        Button("Toast") {
            toast = Toast(style: .success, message: "Easy!")
        }
        .toastView(toast: $toast)  // Works!
    }
}
```

Happy coding without imports! 🎉

# SwiftUIUtilities - Package Structure

## Overview

This document provides a comprehensive overview of the SwiftUIUtilities package structure, explaining the purpose of each module and how they work together.

## Directory Structure

```
SwiftUIUtilities/
├── Package.swift                    # Swift Package Manager manifest
├── README.md                        # Main documentation
├── EXAMPLES.md                      # Detailed usage examples
├── LICENSE                          # MIT License
├── .gitignore                       # Git ignore rules
│
├── Sources/
│   └── SwiftUIUtilities/
│       ├── Core/
│       │   └── Enums/
│       │       └── EnumUtility.swift              # LoadingState, EmptyStateData enums
│       │
│       ├── Extensions/
│       │   ├── ColorExtension.swift               # Color utilities (contrastingTextColor)
│       │   ├── StringExtension.swift              # String helpers & localization
│       │   └── View+Glow.swift                    # Glow shadow effect
│       │
│       ├── Helpers/
│       │   ├── ColorUtility.swift                 # App-wide color scheme
│       │   ├── Logger.swift                       # Logging utility
│       │   └── UIKitBridge.swift                  # UIKit-SwiftUI bridges (GIF support)
│       │
│       ├── Modifiers/
│       │   └── ViewModifier.swift                 # Custom view modifiers collection
│       │
│       ├── Navigation/
│       │   ├── Models/
│       │   │   └── NavigationViewModel.swift      # Navigation data models
│       │   ├── NavigationDestinationEnum.swift    # Type-safe navigation destinations
│       │   └── NavigationService.swift            # Centralized navigation service
│       │
│       ├── Network/
│       │   ├── APIError.swift                     # Comprehensive API error handling
│       │   └── ApiReachabilityManager.swift       # Network connectivity monitoring
│       │
│       ├── Protocols/
│       │   ├── PaginatableViewModel.swift         # Pagination protocol
│       │   └── RoutableViewProtocol.swift         # Routable & request handler protocols
│       │
│       ├── UI/
│       │   ├── Components/
│       │   │   ├── CustomAlertPopupView.swift     # Custom alert system
│       │   │   ├── ShimmerView.swift              # Shimmer loading effect
│       │   │   └── Toast/
│       │   │       ├── Toast.swift                # Toast model
│       │   │       ├── ToastModifier.swift        # Toast view modifier
│       │   │       ├── ToastStyle.swift           # Toast styling
│       │   │       └── ToastView.swift            # Toast view implementation
│       │   ├── SwiftUIUtility.swift               # Reusable UI components library
│       │   └── SwiftUIUtilityModel.swift          # UI utility models
│       │
│       ├── Utilities/
│       │   ├── CustomFontUtility.swift            # Custom font registration
│       │   └── TaskUtility.swift                  # Task cancellation utilities
│       │
│       └── ViewModels/
│           └── RoutableViewModel.swift            # Base view model class
│
└── Tests/
    └── SwiftUIUtilitiesTests/
        └── SwiftUIUtilitiesTests.swift            # Unit tests
```

## Module Descriptions

### Core

**Purpose**: Fundamental enumerations and data structures used across the package.

- `EnumUtility.swift`: Defines core enums
  - `LoadingState`: Manages loading states (loading, loaded, none, progressLoading)
  - `EmptyStateData`: Defines empty state types (noData, error, noConnection, search)

### Extensions

**Purpose**: Extensions to Swift and SwiftUI types for enhanced functionality.

- `ColorExtension.swift`: Color manipulation utilities
  - `contrastingTextColor()`: Returns optimal text color for any background
  
- `StringExtension.swift`: String manipulation and localization
  - Trim, replace, format utilities
  - Localization support via `.localized`
  
- `View+Glow.swift`: Visual effects
  - `glow()` modifier for shadow glow effects

### Helpers

**Purpose**: Utility classes providing app-wide services.

- `ColorUtility.swift`: Centralized color management
  - `primaryColor`, `secondaryColor`
  - Background and text color schemes
  
- `Logger.swift`: Simple logging system
  - Log levels: info, warning, error, debug
  - Singleton pattern
  
- `UIKitBridge.swift`: SwiftUI-UIKit integration
  - `GIFWebView`: Display animated GIFs in SwiftUI

### Modifiers

**Purpose**: Custom view modifiers for common styling patterns.

**Key Modifiers**:
- `cardStyle()`: Card-like appearance with shadows
- `gradientBorder()`: Gradient border effect
- `dynamicTextColor()`: Auto-adjusting text color
- `fontStyle()`: Custom font application
- `customBackButton()`: Custom navigation bar back button
- `stateDrivenView()`: Loading/empty state management
- `versionedLineLimit()`: iOS version-compatible line limits
- `matchToParentContainer()`: Full-size frame helper

### Navigation

**Purpose**: Comprehensive navigation system built on SwiftfulRouting.

- `NavigationService.swift`: Centralized navigation coordinator
  - `navigate()`, `dismissScreen()`, `dismissModal()`
  - Stack and environment dismissal
  
- `NavigationDestinationEnum.swift`: Type-safe destinations
  - Push, modal, sheet, and alert presentations
  - Custom alert integration
  
- `NavigationViewModel.swift`: Navigation data models
  - Alert view model structures

### Network

**Purpose**: Networking utilities and error handling.

- `APIError.swift`: Comprehensive error types
  - Status code mapping
  - Error message extraction
  - Sendable conformance
  
- `ApiReachabilityManager.swift`: Network monitoring
  - Real-time connectivity status
  - WiFi/Cellular detection
  - Notification-based updates

### Protocols

**Purpose**: Protocol definitions for common patterns.

- `PaginatableViewModel.swift`: Pagination protocol
  - `loadInitial()`, `loadMore()`, `refresh()`
  - Automatic page management
  - Loading state integration
  
- `RoutableViewProtocol.swift`: Navigation & API handling
  - Router integration
  - API error handling
  - Loading state management
  - Toast integration
  - Combine publisher extensions

### UI

**Purpose**: Reusable UI components and utilities.

**Components**:
- `ShimmerView`: Animated loading skeleton
- `CustomAlertPopupView`: Alert system with factory methods
- `Toast System`: Non-intrusive notifications

**Utilities**:
- `SwiftUIUtility.swift`: Component library
  - `BackgroundImageView`
  - `GradientDivider`
  - `RoundMenuButton`
  - `ProfileImageView` (multiple variants)
  - `RectangularIconButton`
  - `CircularProgressView`
  - `IconWithText`
  - And many more...

### ViewModels

**Purpose**: Base classes for view models.

- `RoutableViewModel.swift`: Base view model
  - Router integration
  - Combine cancellables management
  - Loading/empty state properties
  - Network availability checking
  - Pagination support
  - Automatic cleanup on deinit

### Utilities

**Purpose**: General-purpose utility functions and helpers.

- `CustomFontUtility.swift`: Font management
  - Custom font registration
  - Font extensions for View
  
- `TaskUtility.swift`: Swift concurrency helpers
  - `AnyCancellableTask`: Type-erased task wrapper

## Dependency Graph

```
┌─────────────────────────┐
│   External Dependencies │
│  - SwiftfulRouting      │
│  - SwiftfulLoading      │
│    Indicators           │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│      Core & Helpers     │
│  - ColorUtility         │
│  - Logger               │
│  - EnumUtility          │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│    Network & Protocols  │
│  - APIError             │
│  - Reachability         │
│  - RoutableProtocol     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│      Navigation         │
│  - NavigationService    │
│  - Destinations         │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│      ViewModels         │
│  - RoutableViewModel    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│      UI Components      │
│  - Toast                │
│  - Alerts               │
│  - Shimmer              │
│  - SwiftUIUtility       │
└─────────────────────────┘
```

## Design Patterns Used

### 1. Protocol-Oriented Programming
- `RoutableViewProtocol`
- `RequestHandlerProtocol`
- `PaginatableViewModel`

### 2. Singleton Pattern
- `NavigationService.shared`
- `ApiReachabilityManager.shared`
- `Logger.shared`

### 3. Factory Pattern
- `CustomAlertPopupModel` factory methods
- Alert type creation

### 4. Observer Pattern
- Network status notifications
- Combine publishers

### 5. Dependency Injection
- Router injection in view models
- Protocol-based dependencies

## Best Practices Implemented

1. **Separation of Concerns**: Each module has a single responsibility
2. **Type Safety**: Enums for navigation destinations and states
3. **Reusability**: Protocols and base classes for common functionality
4. **Testability**: Protocol-based design allows for easy testing
5. **Documentation**: Comprehensive inline documentation
6. **Public API**: Only necessary types are marked public
7. **Memory Management**: Proper cleanup in `deinit` methods
8. **Concurrency**: Swift concurrency with async/await
9. **Error Handling**: Comprehensive error types and handling

## Extension Points

### Adding New Components
1. Create component in `UI/Components/`
2. Add to `SwiftUIUtility` if it's a utility component
3. Document in `EXAMPLES.md`

### Adding New Navigation Destinations
1. Add case to `NavigationDestinationEnum`
2. Implement navigation logic
3. Update navigation tests

### Adding New View Modifiers
1. Add to `Modifiers/ViewModifier.swift`
2. Create extension on `View`
3. Document usage

### Adding New Protocols
1. Create in `Protocols/` directory
2. Provide default implementations
3. Document in README

## Migration Guide

### From Individual Files to Package

If you're migrating from individual files:

1. Remove old files from your project
2. Add SwiftUIUtilities package dependency
3. Update imports from individual files to `import SwiftUIUtilities`
4. Update access levels (some internal → public)
5. Update ColorUtility references if you had custom colors

### Version Compatibility

- Minimum iOS 15.0
- Supports iOS 16+ features with fallbacks
- Swift 5.9+ required

## Performance Considerations

1. **Lazy Loading**: Use LazyVStack/LazyHStack with pagination
2. **State Management**: @Published properties trigger view updates
3. **Memory**: Proper cleanup prevents leaks
4. **Network**: Background dispatch for API calls
5. **UI**: Main actor for UI updates

## Testing Strategy

1. **Unit Tests**: Core logic and utilities
2. **Protocol Tests**: Default implementations
3. **Integration Tests**: Navigation and API handling
4. **UI Tests**: Component rendering (planned)

## Future Enhancements

- [ ] More UI components
- [ ] Additional view modifiers
- [ ] Enhanced error recovery
- [ ] Offline mode support
- [ ] Analytics integration hooks
- [ ] Accessibility improvements
- [ ] Dark mode optimizations
- [ ] Additional localization support

## Contributing

When contributing to this package:

1. Follow existing code structure
2. Add unit tests for new features
3. Update documentation
4. Maintain backward compatibility
5. Use meaningful commit messages

## Support

For questions or issues:
- Check EXAMPLES.md for usage examples
- Review README.md for basic setup
- File issues on GitHub
- Contact: [Your contact info]

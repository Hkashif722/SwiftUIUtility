//
//  DropDownMenuProtocol.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 14/01/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

/// A protocol that represents a standard structure for dropdown menu items.
/// This protocol is designed to provide a consistent interface for models used in dropdown menus.
///
/// Types conforming to this protocol gain the following features:
/// - `Identifiable`: Each dropdown menu item must have a unique identifier (`id`).
/// - `CustomStringConvertible`: Provides a textual representation (`description`) for the dropdown menu item.
/// - `Equatable`: Allows comparison of dropdown menu items for equality.
/// - `Hashable`: Ensures the item can be used in collections such as `Set` or as keys in dictionaries.
///
/// Conformance Requirements:
/// - The `id` property must conform to `Hashable`.
/// - The conforming type can override the default `description` if desired.
public protocol DropDownMenuProtocolPkg: Identifiable, CustomStringConvertible, Equatable, Hashable where ID: Hashable {}


// MARK: - Default Implementation for Equatable
extension DropDownMenuProtocolPkg {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Default Implementation for Hashable
extension DropDownMenuProtocolPkg {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


////MARK: Default behavior for all types
//extension DropDownMenuProtocol {
//    var shouldIgnore: Bool {
//        false
//    }
//}
//
////MARK: Custom behavior for `Int` IDs
//extension DropDownMenuProtocol where ID == Int {
//    var shouldIgnore: Bool {
//        id == -1
//    }
//}


extension DropDownMenuProtocolPkg {
    /// Determines whether the item should be ignored.
    public var shouldIgnore: Bool {
        if let intID = id as? Int {
            return intID == -1
        }
        return false
    }
}

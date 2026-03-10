//
//  PreferenceKeys.swift
//  RolePlayKit
//
//  Created by Kashif Hussain on 17/02/26.
//
import SwiftUI

public struct PreferenceKeys {

    public struct ContentHeightKey: PreferenceKey {
        nonisolated(unsafe) public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    public struct MaxHeightPreferenceKey: PreferenceKey {
        nonisolated(unsafe) public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    public struct ScrollOffsetKey: PreferenceKey {
        nonisolated(unsafe) public static var defaultValue: CGFloat = 0
        public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

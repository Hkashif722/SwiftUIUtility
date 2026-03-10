//
//  TaskUtility.swift
//  SWAYAM 2.0 copy
//
//  Created by Kashif Hussain on 01/05/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import Foundation

public struct TaskUtility {
    
    
    public struct AnyCancellableTask: Hashable {
        private let id = UUID()
        private let cancelClosure: () -> Void
        
        public init<T>(_ task: Task<T, Never>) {
            self.cancelClosure = {
                task.cancel()
            }
        }
        
        func cancel() {
            cancelClosure()
        }
        
        public static func == (lhs: AnyCancellableTask, rhs: AnyCancellableTask) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    
    
}


public extension Task where Success == Never, Failure == Never {
    /// Sleep for a specified duration with automatic version fallback
    /// - Parameter seconds: Duration in seconds
    public static func sleep(seconds: Double) async throws {
        if #available(iOS 16.0, *) {
            try await Task.sleep(for: .seconds(seconds))
        } else {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
    }

}

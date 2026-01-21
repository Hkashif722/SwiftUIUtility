//
//  TaskUtility.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import Foundation

public struct TaskUtility {
    
    public struct AnyCancellableTask: Hashable, Sendable {
        private let id = UUID()
        private let cancelClosure: @Sendable () -> Void
        
        public init<T>(_ task: Task<T, Never>) {
            self.cancelClosure = {
                task.cancel()
            }
        }
        
        public func cancel() {
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

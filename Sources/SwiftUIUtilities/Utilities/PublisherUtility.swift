//
//  PublisherUtility.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import Foundation
import Combine
import UIKit

public struct PublisherUtility {
    
    public struct PublisherBinder<Root: AnyObject> {
        private weak var root: Root?
        private var cancellables: Set<AnyCancellable> = []
        
        public init(root: Root) {
            self.root = root
        }
        
        // Handle optional publishers
        public func bind<T: Equatable>(_ publisher: Published<T>.Publisher?, to keyPath: ReferenceWritableKeyPath<Root, T>) -> Self {
            var new = self
            publisher?
                .removeDuplicates()
                .sink { [weak root] value in
                    root?[keyPath: keyPath] = value
                }
                .store(in: &new.cancellables)
            return new
        }
        
        // Handle non-optional publishers
        public func bind<T: Equatable>(_ publisher: Published<T>.Publisher, to keyPath: ReferenceWritableKeyPath<Root, T>) -> Self {
            var new = self
            publisher
                .removeDuplicates()
                .sink { [weak root] value in
                    root?[keyPath: keyPath] = value
                }
                .store(in: &new.cancellables)
            return new
        }
        
        public func bindWithoutDuplicateRemoval<T>(_ publisher: Published<T>.Publisher?, to keyPath: ReferenceWritableKeyPath<Root, T>) -> Self {
            var new = self
            publisher?
                .sink { [weak root] value in
                    root?[keyPath: keyPath] = value
                }
                .store(in: &new.cancellables)
            return new
        }
        
        // Bind to method calls
        public func bind<T: Equatable>(_ publisher: Published<T>.Publisher, to method: @escaping (T) -> Void) -> Self {
            var new = self
            publisher
                .removeDuplicates()
                .sink { [weak root] value in
                    guard root != nil else { return }
                    method(value)
                }
                .store(in: &new.cancellables)
            return new
        }
        
        // Bind to method calls (optional publisher)
        public func bind<T: Equatable>(_ publisher: Published<T>.Publisher?, to method: @escaping (T) -> Void) -> Self {
            var new = self
            publisher?
                .removeDuplicates()
                .sink { [weak root] value in
                    guard root != nil else { return }
                    method(value)
                }
                .store(in: &new.cancellables)
            return new
        }
        
        // Bind to method calls without duplicate removal
        public func bindWithoutDuplicateRemoval<T>(_ publisher: Published<T>.Publisher, to method: @escaping (T) -> Void) -> Self {
            var new = self
            publisher
                .sink { [weak root] value in
                    guard root != nil else { return }
                    method(value)
                }
                .store(in: &new.cancellables)
            return new
        }
        
        // In PublisherUtility.swift
        public func propagateNestedChanges<T: ObservableObject>(
            from publisher: Published<T>.Publisher
        ) -> Self where Root: ObservableObject, Root.ObjectWillChangePublisher == ObservableObjectPublisher {
            var new = self
            publisher
                .flatMap { $0.objectWillChange }
                .sink { [weak root] _ in
                    guard let root = root else { return }
                    root.objectWillChange.send()
                }
                .store(in: &new.cancellables)
            return new
        }
        
        
        public func store(in cancellables: inout Set<AnyCancellable>) {
            self.cancellables.forEach { $0.store(in: &cancellables) }
        }
    }
}

// Keyboard height publisher
extension Publishers {
    public static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero }
            .map(\.height)

        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

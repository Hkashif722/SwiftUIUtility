//
//  Debouncer.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 27/02/26.
//


import Foundation
import Combine

class Debouncer<T: Equatable> {
    private var cancellable: AnyCancellable?
    private let interval: TimeInterval
    private let subject = PassthroughSubject<T, Never>()
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func debounce(_ value: T, action: @escaping (T) -> Void) {
        // Cancel any existing debounce actions
        cancellable?.cancel()
        
        // Subscribe to the subject and debounce the input
        cancellable = subject
            .debounce(for: .seconds(interval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink(receiveValue: { action($0) })
        
        // Pass the new value to the subject
        subject.send(value)
    }
}

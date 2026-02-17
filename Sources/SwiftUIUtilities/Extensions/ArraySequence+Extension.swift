//
//  ArraySequence+Extension.swift
//  RolePlayKit
//
//  Created by Kashif Hussain on 16/11/25.
//



import Foundation

public extension Sequence where Iterator.Element == String {
    func joinWithPathSeparator() -> String {
        return self.joined(separator: "/")
    }
}

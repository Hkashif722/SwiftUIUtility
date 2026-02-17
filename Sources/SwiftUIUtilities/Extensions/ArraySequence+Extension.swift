//
//  ArraySequence+Extension.swift
//  RolePlayKit
//
//  Created by Kashif Hussain on 16/11/25.
//



import Foundations

extension Sequence where Iterator.Element == String {
    func joinWithPathSeparator() -> String {
        return self.joined(separator: "/")
    }
}

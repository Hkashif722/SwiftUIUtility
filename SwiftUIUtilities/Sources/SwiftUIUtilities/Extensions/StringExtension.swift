//
//  StringExtension.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 16/11/25.
//

import Foundation

public extension String {
    func removeExtraCharactor() -> String {
        var outPutString: String = self
        if self.contains("../") {
            outPutString = self.replace("../", replacement: "")
        }
        return outPutString
    }
    
    func replace(_ string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func replacingHost(with newHost: String) -> String {
        guard var components = URLComponents(string: self), components.host != nil else {
            return self
        }
        components.host = newHost
        return components.string ?? self
    }
    
    func manageExtraCha() -> String {
        var outPutString = self
        if self.contains("\\") {
            outPutString = self.replace("\\", replacement: "/")
        }
        return outPutString
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = formatter.date(from: self) {
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        }
        return self
    }
    
    var localized: String {
        NSLocalizedString(self, bundle: .swiftUIUtilitiesModule, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, bundle: .swiftUIUtilitiesModule, comment: ""), arguments: arguments)
    }
}

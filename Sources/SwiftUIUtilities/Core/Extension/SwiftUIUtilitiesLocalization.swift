//
//  SwiftUIUtilitiesLocalization.swift
//  SwiftUIUtilities
//
//  Runtime language switch for this package's own shared UI strings (empty
//  states, loading, toolbar back title, generic network/auth error copy).
//  Mirrors the identical pattern already used by AcuityIQPackage, OJT_Package,
//  AssessmentKit and RolePlayKit: a dynamic Bundle(path:) lookup keyed off a
//  process-global code, so switching needs no relaunch.
//

import Foundation

public enum SwiftUIUtilitiesLocalization {
    public static func configure(languageCode: String) {
        SwiftUIUtilitiesLocale.configure(languageCode: languageCode)
    }
}

internal enum SwiftUIUtilitiesLocale {
    nonisolated(unsafe) private static var languageCode = "en"

    static func configure(languageCode: String) {
        self.languageCode = normalized(languageCode)
    }

    static var locale: Locale {
        Locale(identifier: languageCode)
    }

    static var bundle: Bundle {
        localizedBundle(for: languageCode)
        ?? localizedBundle(for: "en")
        ?? .swiftUIUtilitiesModule
    }

    static func localizedString(for key: String) -> String {
        let selected = NSLocalizedString(key, bundle: bundle, value: key, comment: "")
        guard selected == key, let englishBundle = localizedBundle(for: "en") else {
            return selected
        }
        return NSLocalizedString(key, bundle: englishBundle, value: key, comment: "")
    }

    private static func localizedBundle(for code: String) -> Bundle? {
        guard let path = Bundle.swiftUIUtilitiesModule.path(forResource: code, ofType: "lproj") else {
            return nil
        }
        return Bundle(path: path)
    }

    private static func normalized(_ code: String) -> String {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "en" }

        if trimmed.caseInsensitiveCompare("ur-in") == .orderedSame {
            return "ur-IN"
        }
        return String(trimmed.prefix(2)).lowercased()
    }
}

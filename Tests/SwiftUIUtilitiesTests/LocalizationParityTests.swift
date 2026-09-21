//
//  LocalizationParityTests.swift
//  SwiftUIUtilities
//
//  Guards the localization table against drift: keys present in one locale but
//  not another, duplicate keys, mismatched `%@` arity (a `String(format:)`
//  crash, not a cosmetic bug), and empty translations. Mirrors the equivalent
//  suite in AcuityIQPackage. Locale list matches the canonical 12 the main app
//  ships (TLS/Resource/*.lproj) and the other 4 packages already carry.
//

import Foundation
import Testing
@testable import SwiftUIUtilities

@Suite(.serialized)
struct LocalizationParityTests {

    static let locales = [
        "en", "hi", "mr", "bn", "as", "or", "ta", "te", "kn", "ml", "ur-IN", "ar"
    ]

    // MARK: - Parsing

    /// `"key" = "value";` — tolerates escaped quotes inside either side.
    private static let entryPattern = try! NSRegularExpression(
        pattern: "^\"((?:[^\"\\\\]|\\\\.)*)\"\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"\\s*;",
        options: [.anchorsMatchLines]
    )

    /// Returns the ordered key/value pairs for a locale, block comments stripped.
    static func entries(for locale: String) throws -> [(key: String, value: String)] {
        let path = try #require(
            Bundle.swiftUIUtilitiesModule.path(forResource: locale, ofType: "lproj"),
            "Missing \(locale).lproj in the package bundle"
        )
        let raw = try String(
            contentsOfFile: path + "/Localizable.strings",
            encoding: .utf8
        )
        // Drop /* ... */ so commented-out entries never count as keys.
        let body = raw.replacingOccurrences(
            of: "/\\*.*?\\*/",
            with: "",
            options: [.regularExpression]
        )
        let ns = body as NSString
        return entryPattern
            .matches(in: body, range: NSRange(location: 0, length: ns.length))
            .map { (ns.substring(with: $0.range(at: 1)),
                    ns.substring(with: $0.range(at: 2))) }
    }

    /// Every format specifier in a value. `localized(with:)` coerces all arguments
    /// through `String(describing:) as NSString`, so anything but `%@` would crash.
    private static func specifiers(in value: String) -> [String] {
        let ns = value as NSString
        let re = try! NSRegularExpression(pattern: "%(?:\\d+\\$)?[@a-zA-Z]")
        return re.matches(in: value, range: NSRange(location: 0, length: ns.length))
            .map { ns.substring(with: $0.range) }
    }

    // MARK: - Tests

    private static let expectedLocales: Set<String> = [
        "ar", "as", "bn", "en", "hi", "kn", "ml", "mr", "or", "ta", "te", "ur-IN"
    ]

    /// Guards against the whole class of bug this package already shipped once
    /// (only 3 of the canonical 12 locales, unnoticed until a manual cross-package
    /// audit): the package's actual shipped locales — not just the `locales` list
    /// above — must exactly match the main app's canonical set (TLS/Resource/*.lproj),
    /// which the other 4 packages also carry.
    @Test func hasExactlyTheCanonicalLocaleSet() {
        let found = Set(Bundle.swiftUIUtilitiesModule.localizations)
        #expect(
            found == Self.expectedLocales,
            """
            locale set drifted from the canonical 12 —
            missing: \(Self.expectedLocales.subtracting(found).sorted())
            extra:   \(found.subtracting(Self.expectedLocales).sorted())
            """
        )
    }

    @Test func everyLocaleParsesAndHasNoDuplicateKeys() throws {
        for locale in Self.locales {
            let keys = try Self.entries(for: locale).map(\.key)
            let duplicates = Dictionary(grouping: keys, by: { $0 })
                .filter { $0.value.count > 1 }
                .keys
                .sorted()
                .joined(separator: ", ")
            #expect(!keys.isEmpty, "\(locale) parsed zero keys")
            #expect(
                duplicates.isEmpty,
                "\(locale) has duplicate keys: \(duplicates)"
            )
        }
    }

    @Test func allLocalesShareTheSameKeySet() throws {
        let english = Set(try Self.entries(for: "en").map(\.key))

        for locale in Self.locales.dropFirst() {
            let keys = Set(try Self.entries(for: locale).map(\.key))
            #expect(
                keys == english,
                """
                \(locale) is out of sync with en.
                missing: \(english.subtracting(keys).sorted().prefix(5))
                extra:   \(keys.subtracting(english).sorted().prefix(5))
                """
            )
        }
    }

    @Test func formatPlaceholdersUseOnlyStringSpecifiersAndMatchArity() throws {
        var tables: [String: [String: String]] = [:]
        for locale in Self.locales {
            tables[locale] = Dictionary(
                uniqueKeysWithValues: try Self.entries(for: locale)
                    .map { ($0.key, $0.value) }
            )
        }

        for key in tables["en"]!.keys.sorted() {
            var arities: Set<Int> = []
            for locale in Self.locales {
                let specs = Self.specifiers(in: tables[locale]![key]!)
                #expect(
                    specs.allSatisfy { $0 == "%@" },
                    "\(locale) key \(key) uses a non-%@ specifier: \(specs)"
                )
                arities.insert(specs.count)
            }
            #expect(
                arities.count == 1,
                "key \(key) has a different placeholder count across locales — String(format:) will crash"
            )
        }
    }

    @Test func noLocaleHasAnEmptyValue() throws {
        for locale in Self.locales {
            for (key, value) in try Self.entries(for: locale) {
                #expect(
                    !value.trimmingCharacters(in: .whitespaces).isEmpty,
                    "\(locale) key \(key) has an empty value — it would render as blank UI"
                )
            }
        }
    }

    /// Keys whose value is legitimately identical (or ASCII-only) across every
    /// locale — a confirmed proper noun, acronym, or brand term, not a translation
    /// gap. Add to this only after confirming the value really should stay as-is.
    private static let allowedUntranslatedKeys: Set<String> = []

    /// Catches a locale file that passes every structural check above (same keys,
    /// no duplicates, no empty values) but still isn't actually translated: a value
    /// left as a verbatim English sentence, or rewritten but never localized into
    /// the target script. Flags any value over 15 characters containing a space
    /// that is either byte-identical to English or entirely ASCII — long/short
    /// enough that a real acronym or brand name never trips this.
    @Test func nonEnglishLocalesContainNoUntranslatedEnglishSentences() throws {
        let english = Dictionary(
            uniqueKeysWithValues: try Self.entries(for: "en").map { ($0.key, $0.value) }
        )
        for locale in Self.locales where locale != "en" {
            for (key, value) in try Self.entries(for: locale) {
                guard !Self.allowedUntranslatedKeys.contains(key) else { continue }
                let trimmed = value.trimmingCharacters(in: .whitespaces)
                guard trimmed.count > 15, trimmed.contains(" ") else { continue }
                let looksUntranslated = trimmed == english[key] || trimmed.allSatisfy(\.isASCII)
                #expect(
                    !looksUntranslated,
                    "\(locale) key \(key) looks untranslated (still English): \(trimmed.prefix(60))"
                )
            }
        }
    }
}

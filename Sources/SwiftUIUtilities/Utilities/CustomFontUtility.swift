//
//  CustomFontUtility.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 05/01/26.
//

import SwiftUI
import CoreText

public extension Font {
    enum Custom: String, Sendable, CaseIterable {
        case inter = "Inter"
    }

    static func custom(_ font: Custom, size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .custom(font.rawValue, size: size).weight(weight)
    }
}

public extension View {
    func appFont(_ font: Font.Custom, size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.custom(font.rawValue, size: size).weight(weight))
    }
}

public enum FontRegistrar {
    public static func registerAllFonts() {
        register(fontName: "Inter-VariableFont_opsz,wght")
    }

    private static func register(fontName: String) {
        let bundle = Bundle.swiftUIUtilitiesModule

        let url = bundle.url(forResource: fontName, withExtension: "ttf")
            ?? bundle.url(forResource: fontName, withExtension: "otf")

        guard let url else {
            print("⚠️ Font not found: \(fontName)")
            return
        }

        guard let dataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(dataProvider)
        else {
            print("⚠️ Unable to load font data: \(fontName)")
            return
        }

        CTFontManagerRegisterGraphicsFont(font, nil)
    }
}

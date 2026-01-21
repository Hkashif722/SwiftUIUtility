//
//  ColorUtility.swift
//  GamificationPackage
//
//  Created by Kashif Hussain on 14/11/25.
//

import SwiftUI

public struct ColorUtility {
    
    public static let primaryColor: Color = Color(hex:"#ee1c24")
    public static let secondaryColor: Color = Color(hex: "#ffd36f")
    public static let tertiaryColor: Color = Color(hex: "#e9e9e9")
    public static let deepBlue = Color(hex: "#1f3c69")
    public static let deepYellow = Color(hex: "EFB036")
    public static let deepGreen = Color(hex: "#2f8752")
    public static let progressBarGreen = Color(hex: "#2f8752")
    public static let prgressBarYellow = Color(hex: "#e9c02d")
    public static let progressBarGray = Color(hex: "#919598")
    
    //MARK: Custom Color
    public static let customGray = Color(hex: "#495057")
    public static let ojtCardLightYellowBGColor = Color(hex: "#fff8e8")
    public static let viewBackgroundColorSecondary = Color(hex: "F8FAFC")
    
    public static var label: Color {
        #if os(iOS)
        return Color(UIColor.label)
        #elseif os(macOS)
        return Color(NSColor.labelColor)
        #else
        return Color.primary
        #endif
    }
    
}

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

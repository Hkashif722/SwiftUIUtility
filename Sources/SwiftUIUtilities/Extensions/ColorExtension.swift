//
//  ColorExtension.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import SwiftUI

public extension Color {
    /// Returns black or white color for optimal contrast against this background color
    func contrastingTextColor() -> Color {
        guard let components = self.cgColor?.components else {
            return .white
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        // Calculate relative luminance using WCAG formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // If luminance > 0.5, background is light, use black text
        // Otherwise, background is dark, use white text
        return luminance > 0.5 ? .black : .white
    }

     func isLight() -> Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        // Standard luminance calculation
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.7
    }

    var getDynamicTextColor: Color {
        isLight() ? .black : .white
    }
}

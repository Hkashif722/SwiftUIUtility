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
}

//
//  View+Glow.swift
//  SwiftUIUtilities
//
//  Created by Ondrej Kvasnovsky on 1/30/23.
//

import Foundation
import SwiftUI

public extension View {
    func glowPkg(color: SwiftUI.Color = .gray, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}


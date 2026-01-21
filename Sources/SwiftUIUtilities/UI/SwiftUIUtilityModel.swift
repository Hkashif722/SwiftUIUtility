//
//  SwiftUIUtilityModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 07/01/26.
//

import SwiftUI

public struct SwiftUIUtilityModel {
    
    public enum FontStyle: Sendable {
        case system(Font)
        case custom(Font.Custom, size: CGFloat, weight: Font.Weight)
    }
}

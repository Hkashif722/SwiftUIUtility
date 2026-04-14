//
//  FilterDropDownTypeKey.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 27/02/26.
//

import SwiftUI

struct EnvironmentKeyModule {
    
    // 2. Create a custom environment key
     struct FilterDropDownTypeKey: EnvironmentKey {
        static let defaultValue: FilterDropDownTypeOptionPkg = .custom
    }
}

// 3. Extend EnvironmentValues to provide easy access
extension EnvironmentValues {
    public var filterDropDownTypePkg: FilterDropDownTypeOptionPkg {
        get { self[EnvironmentKeyModule.FilterDropDownTypeKey.self] }
        set { self[EnvironmentKeyModule.FilterDropDownTypeKey.self] = newValue }
    }
}

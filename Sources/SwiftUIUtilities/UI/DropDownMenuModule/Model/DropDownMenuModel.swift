//
//  DropDownMenuModel.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 30/12/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//

import Foundation


public struct DropDownMenuModelPkg: Identifiable, DropDownMenuProtocolPkg {
    
    public let id: Int
    public let title: String
    
    public var description: String { title }
    
    public init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}

//
//  DropDownView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 30/12/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//

import SwiftUI

struct DropDownView<Control, Dropdown>: View where Control: View, Dropdown: View {
    @Environment(\.filterDropDownType) var dropdownType
    @Binding var show: Bool
    let control: () -> Control
    let dropdown: () -> Dropdown

    var body: some View {
        
        dropDownView
    }
    
    @ViewBuilder
    private var dropDownView: some View {
        
        switch dropdownType {
            
        case .system:
            systemDropDownView
            
        case .custom:
            customDropDownView
        }
    }
    
    
    private var customDropDownView: some View {
        control()
            .opacity(show ? 0.7 : 1.0)
            .onTapGesture {
                show.toggle()
            }
            .overlay(alignment: .bottomLeading) {
                Group {
                    if show {
                        dropdown()
                            .transition(.opacity)
//                            .zIndex(1)
                    }
                }
                .alignmentGuide(.bottom) { $0[.top] }
            }
            .animation(.easeOut(duration: 0.2), value: show)
    }
    
    private var systemDropDownView: some View {
        Menu {
            // The dropdown content (menu items) is defined here.
            dropdown()
        } label: {
            // This is the control view that triggers the menu.
            control()
        }
    }
}




//import SwiftUI
//
//struct DropDownView<Control, Dropdown>: View where Control: View, Dropdown: View {
//    @Binding var show: Bool
//    let control: () -> Control
//    let dropdown: () -> Dropdown
//
//    var body: some View {
//        Menu {
//            // The dropdown content (menu items) is defined here.
//            dropdown()
//        } label: {
//            // This is the control view that triggers the menu.
//            control()
//        }
//    }
//}


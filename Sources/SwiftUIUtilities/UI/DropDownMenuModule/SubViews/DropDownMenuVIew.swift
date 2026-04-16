//
//  DropDownMenuVIew.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 30/12/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//

import SwiftUI

struct DropdownMenuView<T>: View where T: DropDownMenuProtocolPkg {
    // MARK: - Properties
    @Binding var selectedOption: T?
    @Binding var isDropdownVisible: Bool
    @Binding var searchText: String
    let menuOptions: [T]
    let placeholder: String
    let controlHeight: CGFloat
    let maxContentHeight: CGFloat
    let font: Font
    let backgroundColor: Color
    let selectedBackgroundColor: Color
    let onSelection: ((T) -> Void)?
    let isSearchable: Bool // Determines if the TextField is editable

    // Focus state to programmatically control the focus of the TextField
    @FocusState private var isTextFieldFocused: Bool

    // MARK: - Body
    var body: some View {
        DropDownView(show: $isDropdownVisible) {
            controlView
        } dropdown: {
            dropdownContent
        }
    }

    // MARK: - Control View
    private var controlView: some View {
        HStack {
            if isSearchable {
                // Editable TextField (Search Bar)
                TextField(
                    (selectedOption == nil ? placeholder : selectedOption?.description) ?? "Select Option",
                    text: $searchText
                )
                .foregroundStyle(searchText.isEmpty ? .gray : .primary)
                .font(font)
                .focused($isTextFieldFocused)
                .autocorrectionDisabled(true)
            } else {
                // Non-editable TextField (acts like a Button)
                Text(selectedOption?.description ?? placeholder) 
                    .foregroundColor(selectedOption == nil ? .gray : .primary)
                    .font(font)
                    .minimumScaleFactor(0.5)
            }

            Spacer()

            Divider()

            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
                .rotationEffect(.degrees(isDropdownVisible ? 180 : 0)) // Rotate when dropdown is shown
                .animation(.easeInOut(duration: 0.2), value: isDropdownVisible) // Smooth rotation animation
                .padding(8)
        }
        .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
        .frame(height: controlHeight)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke((isDropdownVisible || selectedOption != nil) ? ColorUtility.deepBlue : Color.gray, lineWidth: 1) // Change border color when shown
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDropdownVisible ? selectedBackgroundColor : (selectedOption != nil ? selectedBackgroundColor : backgroundColor)) // Use custom background colors
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isDropdownVisible) // Smooth transitions
    }

    // MARK: - Dropdown Content
    private var dropdownContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(menuOptions) { menu in
                    Button(action: {
                        handleSelection(for: menu)
                    }) {
                        dropdownButtonContent(for: menu)
                    }
                    .hoverEffect(.highlight) // Adds subtle interaction feedback for hover-capable devices.
                }
            }
            
        }
        .frame(height: min(CGFloat(menuOptions.count * 44), maxContentHeight))
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .applyScrollBounceBehaviorPkg()
    }

    // MARK: - Helper Methods
    private func handleSelection(for menu: T) {
        guard !menu.shouldIgnore else { return }
//        selectedOption = menu
//        searchText = menu.description
//        isDropdownVisible = false // Close dropdown after selection
        isTextFieldFocused = false // Remove focus from the TextField
        onSelection?(menu)
    }

    private func dropdownButtonContent(for menu: T) -> some View {
        HStack {
            Text(menu.description)
                .font(font)
                .multilineTextAlignment(.leading)
                .foregroundColor(menu.shouldIgnore ? .red : .primary)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .opacity(selectedOption?.id == menu.id ? 0.3 : 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: selectedOption?.id == menu.id ? 1.5 : 0)
        )
        .contentShape(Rectangle()) // Makes the whole area tappable.
    }
}

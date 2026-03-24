//
//  DropDownMenuView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 30/12/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//


import SwiftUI

public struct DropDownMenuListViewPkg<T>: View where T: DropDownMenuProtocolPkg {

    @State private var selectedOption: T?
    @State private var isDropdownVisible: Bool = false
    @State private var searchText: String = ""
    @State private var suppressSearch: Bool = false // Flag to suppress search on selection
    @State private var debouncer = Debouncer<String>(interval: 0.5)

    private let menuOptions: [T]
    private let placeholder: String
    private let isSearchable: Bool
    private let controlHeight: CGFloat
    private let maxContentHeight: CGFloat
    private let font: Font
    private let backgroundColor: Color
    private let selectedBackgroundColor: Color

    // Callbacks
    var onSearchTextChange: ((String) -> Void)?
    var onDropDownSelect: ((T) -> Void)?

    public init(
        _ menuOptions: [T],
        placeholder: String = "Select an Option",
        selectedOption: T? = nil,
        isSearchable: Bool = false,
        controlHeight: CGFloat = 45,
        maxContentHeight: CGFloat = 160.0,
        font: Font = .headline,
        backgroundColor: Color = .clear,
        selectedBackgroundColor: Color = Color(uiColor: .systemGray6),
        onSearchTextChange: ((String) -> Void)? = nil,
        onSelection: ((T) -> Void)? = nil
    ) {
        self.menuOptions = menuOptions
        self.placeholder = placeholder
        self._selectedOption = State(initialValue: selectedOption)
        self._searchText = State(initialValue: selectedOption?.description ?? "")
        self.isSearchable = isSearchable
        self.controlHeight = controlHeight
        self.maxContentHeight = maxContentHeight
        self.font = font
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.onSearchTextChange = onSearchTextChange
        self.onDropDownSelect = onSelection
    }

    public var body: some View {
        DropdownMenuView(
            selectedOption: $selectedOption,
            isDropdownVisible: $isDropdownVisible,
            searchText: $searchText,
            menuOptions: menuOptions,
            placeholder: placeholder,
            controlHeight: controlHeight,
            maxContentHeight: maxContentHeight,
            font: font,
            backgroundColor: backgroundColor,
            selectedBackgroundColor: selectedBackgroundColor,
            onSelection: { selectedMenu in
                suppressSearch = true
                selectedOption = selectedMenu
                onDropDownSelect?(selectedMenu)
                searchText = selectedMenu.description
                isDropdownVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    suppressSearch = false
                }
            },
            isSearchable: isSearchable
        )
        .onChange(of: searchText) { newSearchText in
            if !suppressSearch {
                debouncer.debounce(newSearchText) { debouncedText in
                    onSearchTextChange?(debouncedText)
                }
            }
        }
        .onChange(of: menuOptions) { data in
            /// Ensure `isDropdownVisible` stays true if `menuOptions` is not empty for the case where` isSearchable` is true
            guard isSearchable else {
                data.isEmpty ? selectedOption = nil : nil
                return
            }
            isDropdownVisible = !data.isEmpty
        }
    }
}

#Preview {
    
    let menuOptions = [
        DropDownMenuModelPkg(id: 1, title: "Menu Item 111"),
        DropDownMenuModelPkg(id: 2, title: "Menu Item 2"),
        DropDownMenuModelPkg(id: 3, title: "Menu Item 3")
    ]
    
    return VStack(spacing: 20) {
        DropDownMenuListViewPkg(
            menuOptions,
            isSearchable: true,
            onSearchTextChange: { searchText in print(searchText) }
        ) { selectedMenu in
            print("Selected id: \(selectedMenu.id)")
        }
        .zIndex(3)
        // Give a higher zIndex if this dropdown is active
        
        
        DropDownMenuListViewPkg(
            menuOptions,
            isSearchable: true,
            onSearchTextChange: { searchText in print(searchText) }
        ) { selectedMenu in
            print("Selected id: \(selectedMenu.id)")
    
        }
        .zIndex(2)
        
        DropDownMenuListViewPkg(
            menuOptions,
            isSearchable: true,
            onSearchTextChange: { searchText in print(searchText) }
        ) { selectedMenu in
            print("Selected id: \(selectedMenu.id)")
        
        }
        .zIndex(1)
    }
    
}

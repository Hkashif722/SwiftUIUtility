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
    /// Incrementing token that asks the search field to clear itself and take focus.
    /// Each new value is one focus request; `nil` means the caller never requests focus.
    private let focusRequest: Int?
    /// The selection as the caller currently sees it. The `@State` above can only be seeded
    /// once, so this is what the control watches to stay in step with its owner — see
    /// `syncWithCaller`.
    private let callerSelection: T?

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
        focusRequest: Int? = nil,
        onSearchTextChange: ((String) -> Void)? = nil,
        onSelection: ((T) -> Void)? = nil
    ) {
        self.menuOptions = menuOptions
        self.placeholder = placeholder
        self._selectedOption = State(initialValue: selectedOption)
        self._searchText = State(initialValue: selectedOption?.description ?? "")
        self.callerSelection = selectedOption
        self.isSearchable = isSearchable
        self.controlHeight = controlHeight
        self.maxContentHeight = maxContentHeight
        self.font = font
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.focusRequest = focusRequest
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
            isSearchable: isSearchable,
            focusRequest: focusRequest
        )
        .onChange(of: callerSelection) { newSelection in
            syncWithCaller(newSelection)
        }
        .onChange(of: focusRequest) { _ in
            /// A focus request starts a fresh search: clear the text and the previous
            /// selection so the field shows its placeholder again. `DropdownMenuView`
            /// takes the keyboard focus off the same token.
            searchText = ""
            selectedOption = nil
        }
        .onChange(of: searchText) { newSearchText in
            if !suppressSearch {
                // An emptied box represents no selection. Holding on to the old one left
                // the control reporting a value nothing on screen showed.
                if newSearchText.isEmpty { selectedOption = nil }
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

    /// Adopts a selection the owner changed on its own — most importantly `nil`.
    ///
    /// The control keeps the shown value in `@State`, which `State(initialValue:)` seeds
    /// only on the first init. Without this, a caller that reset its selection (a filter
    /// parameter changed, a parent field was re-picked) was left with the *previous* value
    /// still on screen and no way to clear it, because passing `nil` did nothing.
    ///
    /// Only runs on an actual change, so a caller that always passes `nil` — the search
    /// dropdowns that let this control own the choice — is never clobbered.
    private func syncWithCaller(_ newSelection: T?) {
        guard newSelection != selectedOption else { return }
        // A programmatic change is not the user typing: keep it out of the search callback,
        // which would otherwise re-query and spring the menu open. Same guard the selection
        // path uses.
        suppressSearch = true
        selectedOption = newSelection
        searchText = newSelection?.description ?? ""
        // A cleared selection means the owner started over; leaving the list open above a
        // placeholder would offer stale options.
        if newSelection == nil { isDropdownVisible = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            suppressSearch = false
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

//
//  DatePickerView.swift
//  SwiftUIUtilities
//
//  Reusable modal calendar for selecting a date with optional min/max bounds.
//

import SwiftUI
import SwiftfulRouting

struct DatePickerView: View {

    @StateObject private var viewModel: DatePickerViewModel

    init(navModel: NavigationViewModel.DatePickerNavModel, router: AnyRouter) {
        _viewModel = StateObject(
            wrappedValue: DatePickerViewModel(navModel: navModel, router: router)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "Select a Date",
                selection: $viewModel.selectedDate,
                in: dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(ColorUtility.primaryColor)
            .background(.white)
            .disabled(isSelectionDisabled)
            .cardStylePkg(
                backgroundColor: Color(.systemBackground),
                cornerRadius: 20,
                shadowColor: .gray.opacity(0.3),
                shadowRadius: 10,
                padding: 8
            )
            .overlay(alignment: .topTrailing) {
                Button(action: { viewModel.onSelectDate() }) {
                    Text("Done")
                        .font(.headline)
                        .frame(width: 70, height: 25)
                        .background(ColorUtility.primaryColor)
                        .foregroundColor(ColorUtility.primaryColor.getDynamicTextColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 5)
                .offset(x: -77, y: 30)
                .disabled(isSelectionDisabled)
                .opacity(isSelectionDisabled ? 0.5 : 1)
            }
        }
        .padding()
    }

    // MARK: - Selection Disabled
    /// When the configured minimum date exceeds the maximum date, the selectable
    /// range is empty: the calendar is shown but interaction is disabled.
    private var isSelectionDisabled: Bool {
        let navModel = viewModel.datePickerNavModel
        guard let lower = navModel.minimumDate, let upper = navModel.maximumDate else { return false }
        return lower > upper
    }

    // MARK: - Date Range
    private var dateRange: ClosedRange<Date> {
        let navModel = viewModel.datePickerNavModel
        let lower: Date = navModel.minimumDate ?? .distantPast

        let upper: Date
        if let maxDate = navModel.maximumDate {
            upper = maxDate
        } else if navModel.allowFutureDates {
            upper = .distantFuture
        } else {
            upper = Calendar.current.startOfDay(for: Date())
        }

        return lower <= upper ? lower...upper : lower...lower
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    DatePickerView(
        navModel: NavigationViewModel.DatePickerNavModel(
            initialDate: Date(),
            allowFutureDates: true,
            onDateSelected: { print($0) }
        ),
        router: router
    )
}

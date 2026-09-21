//
//  DatePickerView.swift
//  SwiftUIUtilities
//
//  Reusable modal calendar for selecting a date with optional min/max bounds.
//
//  Two layouts, chosen by the nav model: the system graphical calendar (the default) and
//  `CalendarGridView`, used when the caller excludes weekdays — something the graphical
//  picker's contiguous range cannot express.
//

import SwiftUI
import SwiftfulRouting

struct DatePickerView: View {

    @StateObject private var viewModel: DatePickerViewModel

    init(navModel: NavigationViewModel.SUIDatePickerNavModel, router: AnyRouter) {
        _viewModel = StateObject(
            wrappedValue: DatePickerViewModel(navModel: navModel, router: router)
        )
    }

    var body: some View {
        if viewModel.usesWeekdayExclusions {
            gridCalendar
        } else {
            graphicalCalendar
        }
    }

    // MARK: - Graphical calendar (default)

    private var graphicalCalendar: some View {
        VStack(spacing: 16) {
            DatePicker(
                "Select a Date",
                selection: $viewModel.selectedDate,
                in: viewModel.dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(ColorUtility.primaryColor)
            .background(.white)
            .disabled(viewModel.isSelectionDisabled)
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
                .disabled(viewModel.isSelectionDisabled)
                .opacity(viewModel.isSelectionDisabled ? 0.5 : 1)
            }
        }
        .padding()
    }

    // MARK: - Grid calendar (weekday exclusions)

    private var gridCalendar: some View {
        VStack(spacing: 16) {
            CalendarGridView(viewModel: viewModel)

            Button(action: { viewModel.onSelectDate() }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(ColorUtility.primaryColor)
                    .foregroundColor(ColorUtility.primaryColor.getDynamicTextColor)
                    .cornerRadius(10)
            }
            .disabled(!viewModel.canCommit)
            .opacity(viewModel.canCommit ? 1 : 0.5)
        }
        .padding()
        .cardStylePkg(
            backgroundColor: Color(.systemBackground),
            cornerRadius: 20,
            shadowColor: .gray.opacity(0.3),
            shadowRadius: 10,
            padding: 8
        )
        .padding()
    }
}

@available(iOS 17.0, *)
#Preview("Graphical") {
    @Previewable @Environment(\.router) var router
    DatePickerView(
        navModel: NavigationViewModel.SUIDatePickerNavModel(
            initialDate: Date(),
            allowFutureDates: true,
            onDateSelected: { print($0) }
        ),
        router: router
    )
}

@available(iOS 17.0, *)
#Preview("No Sundays") {
    @Previewable @Environment(\.router) var router
    DatePickerView(
        navModel: NavigationViewModel.SUIDatePickerNavModel(
            initialDate: Date(),
            allowFutureDates: true,
            disabledWeekdays: [1],
            onDateSelected: { print($0) }
        ),
        router: router
    )
}

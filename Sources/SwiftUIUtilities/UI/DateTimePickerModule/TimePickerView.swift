//
//  TimePickerView.swift
//  SwiftUIUtilities
//
//  Reusable modal wheel for selecting a time of day.
//

import SwiftUI
import SwiftfulRouting

struct TimePickerView: View {

    @StateObject private var viewModel: TimePickerViewModel

    init(navModel: NavigationViewModel.SUITimePickerNavModel, router: AnyRouter) {
        _viewModel = StateObject(
            wrappedValue: TimePickerViewModel(navModel: navModel, router: router)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            DatePicker(
                "Select a Time",
                selection: $viewModel.selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .tint(ColorUtility.primaryColor)
            .environment(\.locale, pickerLocale)

            Button(action: { viewModel.onSelectTime() }) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(ColorUtility.primaryColor)
                    .foregroundColor(ColorUtility.primaryColor.getDynamicTextColor)
                    .cornerRadius(10)
            }
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
        .onAppear { applyMinuteInterval() }
    }

    private func applyMinuteInterval() {
        UIDatePicker.appearance().minuteInterval = viewModel.timePickerNavModel.minuteInterval
    }

    /// SwiftUI's wheel follows the environment locale rather than the formatter used by
    /// the text field. `en_GB` has a 24-hour default and therefore removes the AM/PM wheel.
    private var pickerLocale: Locale {
        viewModel.timePickerNavModel.uses24HourClock
            ? Locale(identifier: "en_GB")
            : .current
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    TimePickerView(
        navModel: NavigationViewModel.SUITimePickerNavModel(
            initialTime: Date(),
            onTimeSelected: { print($0) }
        ),
        router: router
    )
}

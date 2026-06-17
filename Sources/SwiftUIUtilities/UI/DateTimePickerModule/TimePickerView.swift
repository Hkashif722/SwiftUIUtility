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

    init(navModel: NavigationViewModel.TimePickerNavModel, router: AnyRouter) {
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
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    TimePickerView(
        navModel: NavigationViewModel.TimePickerNavModel(
            initialTime: Date(),
            onTimeSelected: { print($0) }
        ),
        router: router
    )
}

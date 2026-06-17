//
//  TimePickerTextField.swift
//  SwiftUIUtilities
//
//  Reusable labelled time field that opens the shared time-wheel modal.
//

import SwiftUI
import SwiftfulRouting

public struct TimePickerTextField: View {

    @State private var selectedTime: Date?

    private let router: AnyRouter
    private let title: String
    private let placeHolder: String
    private let timeFormat: String
    private let minuteInterval: Int
    private let isEnabled: Bool
    private let initialTimeString: String?
    private let onTimeSelected: (_ selectedTime: String) -> Void

    public init(
        router: AnyRouter,
        title: String,
        placeHolder: String = "Select time",
        timeFormat: String = "h:mm a",
        minuteInterval: Int = 1,
        isEnabled: Bool = true,
        initialTimeString: String? = nil,
        onTimeSelected: @escaping (String) -> Void
    ) {
        self.router = router
        self.title = title
        self.placeHolder = placeHolder
        self.timeFormat = timeFormat
        self.minuteInterval = minuteInterval
        self.isEnabled = isEnabled
        self.initialTimeString = initialTimeString
        self.onTimeSelected = onTimeSelected
    }

    // MARK: - Computed
    private var borderColor: Color {
        (selectedTime != nil || initialTimeString?.isEmpty == false) ? ColorUtility.deepBlue : ColorUtility.customGray
    }

    private var displayTime: Date? {
        selectedTime ?? initialTimeString.flatMap { parseTime($0) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))

            Button(action: { if isEnabled { showTimePickerModal() } }) {
                HStack {
                    Text(displayTime != nil ? formattedTime(displayTime!) : placeHolder)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(displayTime != nil ? .primary : .secondary)
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundColor(isEnabled ? ColorUtility.primaryColor : .gray)
                }
                .padding(12)
                .background(isEnabled ? .white : Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!isEnabled)
        }
        .task { updateSelectedTime() }
    }

    // MARK: - Helpers
    private func updateSelectedTime() {
        if selectedTime == nil, let str = initialTimeString, !str.isEmpty {
            selectedTime = parseTime(str)
        }
    }

    private func showTimePickerModal() {
        let initialTime = selectedTime ?? Date()
        let navModel = NavigationViewModel.TimePickerNavModel(
            initialTime: initialTime,
            minuteInterval: minuteInterval,
            onTimeSelected: { time in
                self.selectedTime = time
                self.onTimeSelected(formattedTime(time))
            }
        )
        NavigationService.shared.navigate(using: router, to: NavigationDestination.timePicker(navModel))
    }

    private func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat
        formatter.locale = Locale.current
        return formatter.string(from: time)
    }

    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = timeFormat
        formatter.locale = Locale.current
        return formatter.date(from: timeString)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    TimePickerTextField(
        router: router,
        title: "Start time",
        onTimeSelected: { print($0) }
    )
    .padding()
}

//
//  DatePickerTextField.swift
//  SwiftUIUtilities
//
//  Reusable labelled date field that opens the shared calendar modal.
//  Date format is read from `SwiftUtilityEnvironment.shared.config.configurableDate`.
//

import SwiftUI
import SwiftfulRouting

public struct DatePickerTextField: View {

    @State private var selectedDate: Date?

    private let router: AnyRouter
    private let title: String
    private let placeHolder: String?
    private let configuredDateFormat: String
    private let allowFutureDates: Bool
    private let minimumDate: Date?
    private let maximumDate: Date?
    private let isEnabled: Bool
    private let initialDateString: String?
    private let onDateSelected: (_ selectedDate: String) -> Void

    public init(
        router: AnyRouter,
        title: String,
        placeHolder: String? = nil,
        allowFutureDates: Bool = true,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        isEnabled: Bool = true,
        initialDateString: String? = nil,
        onDateSelected: @escaping (String) -> Void
    ) {
        self.router = router
        self.title = title
        self.placeHolder = placeHolder
        self.allowFutureDates = allowFutureDates
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.isEnabled = isEnabled
        self.initialDateString = initialDateString
        self.configuredDateFormat = SwiftUtilityEnvironment.shared.config.configurableDate
        self.onDateSelected = onDateSelected
    }

    // MARK: - Computed
    private var borderColor: Color {
        (selectedDate != nil || initialDateString?.isEmpty == false) ? ColorUtility.deepBlue : ColorUtility.customGray
    }

    private var displayDate: Date? {
        selectedDate ?? initialDateString.flatMap { parseDate($0) }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(.darkGray))

            Button(action: { if isEnabled { showDatePickerModal() } }) {
                HStack {
                    selectedDateView
                    Spacer()
                    Image(systemName: "calendar")
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
        .task { updateSelectedDate() }
    }

    private var selectedDateView: some View {
        Text(displayDate != nil ? formattedDate(displayDate!) : (placeHolder ?? configuredDateFormat))
            .font(.system(size: 16, weight: .medium))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundColor(displayDate != nil ? .primary : .secondary)
    }

    // MARK: - Helpers
    private func updateSelectedDate() {
        if selectedDate == nil, let str = initialDateString, !str.isEmpty {
            selectedDate = parseDate(str)
        }
    }

    private func showDatePickerModal() {
        let initialDate = selectedDate ?? minimumDate ?? Date()
        let navModel = NavigationViewModel.DatePickerNavModel(
            initialDate: initialDate,
            allowFutureDates: allowFutureDates,
            minimumDate: minimumDate,
            maximumDate: maximumDate,
            onDateSelected: { date in
                self.selectedDate = date
                self.onDateSelected(formattedDate(date))
            }
        )
        NavigationService.shared.navigate(using: router, to: NavigationDestination.datePicker(navModel))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = configuredDateFormat
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = configuredDateFormat
        formatter.locale = Locale.current
        if let date = formatter.date(from: dateString) { return date }
        return ResourceUtils.dynamicDateFormat(dateString).date
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    DatePickerTextField(
        router: router,
        title: "Start date",
        placeHolder: "Select start date",
        onDateSelected: { print($0) }
    )
    .padding()
}

//
//  NavigationViewModel+DateTimePicker.swift
//  SwiftUIUtilities
//
//  Shared navigation models for the reusable Date / Time pickers.
//

import Foundation

public extension NavigationViewModel {

    // MARK: - Date Picker
    struct SUIDatePickerNavModel {
        public let initialDate: Date
        public let allowFutureDates: Bool
        public let minimumDate: Date?
        public let maximumDate: Date?
        public let onDateSelected: (Date) -> Void

        public init(
            initialDate: Date,
            allowFutureDates: Bool = true,
            minimumDate: Date? = nil,
            maximumDate: Date? = nil,
            onDateSelected: @escaping (Date) -> Void
        ) {
            self.initialDate = initialDate
            self.allowFutureDates = allowFutureDates
            self.minimumDate = minimumDate
            self.maximumDate = maximumDate
            self.onDateSelected = onDateSelected
        }
    }

    // MARK: - Time Picker
    struct SUITimePickerNavModel {
        public let initialTime: Date
        public let minuteInterval: Int
        public let onTimeSelected: (Date) -> Void

        public init(
            initialTime: Date,
            minuteInterval: Int = 1,
            onTimeSelected: @escaping (Date) -> Void
        ) {
            self.initialTime = initialTime
            self.minuteInterval = minuteInterval
            self.onTimeSelected = onTimeSelected
        }
    }
}

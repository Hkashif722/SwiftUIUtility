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
        /// Weekdays that cannot be picked, in `Calendar` numbering (1 = Sunday … 7 = Saturday).
        ///
        /// Empty (the default) keeps the system graphical calendar. Any entry switches the
        /// modal to a month grid that renders those weekdays dimmed and un-tappable — the
        /// graphical `DatePicker` only understands a contiguous min/max range and cannot
        /// exclude a repeating weekday.
        public let disabledWeekdays: Set<Int>
        public let onDateSelected: (Date) -> Void

        public init(
            initialDate: Date,
            allowFutureDates: Bool = true,
            minimumDate: Date? = nil,
            maximumDate: Date? = nil,
            disabledWeekdays: Set<Int> = [],
            onDateSelected: @escaping (Date) -> Void
        ) {
            self.initialDate = initialDate
            self.allowFutureDates = allowFutureDates
            self.minimumDate = minimumDate
            self.maximumDate = maximumDate
            self.disabledWeekdays = disabledWeekdays
            self.onDateSelected = onDateSelected
        }
    }

    // MARK: - Time Picker
    struct SUITimePickerNavModel {
        public let initialTime: Date
        public let minuteInterval: Int
        public let uses24HourClock: Bool
        public let onTimeSelected: (Date) -> Void

        public init(
            initialTime: Date,
            minuteInterval: Int = 1,
            uses24HourClock: Bool = false,
            onTimeSelected: @escaping (Date) -> Void
        ) {
            self.initialTime = initialTime
            self.minuteInterval = minuteInterval
            self.uses24HourClock = uses24HourClock
            self.onTimeSelected = onTimeSelected
        }
    }
}

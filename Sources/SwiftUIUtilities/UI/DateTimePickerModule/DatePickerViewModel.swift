//
//  DatePickerViewModel.swift
//  SwiftUIUtilities
//
//  Reusable date-picker modal view model. Owns the selectable window, the
//  weekday exclusions, and the month grid the calendar renders when any
//  weekday is excluded.
//

import Foundation
import SwiftfulRouting

final class DatePickerViewModel: RoutableViewModel {

    let datePickerNavModel: NavigationViewModel.SUIDatePickerNavModel

    @Published var selectedDate: Date
    /// Month the grid is showing. Unused by the graphical-calendar path.
    @Published var displayedMonth: Date

    private let calendar: Calendar = .current

    init(navModel: NavigationViewModel.SUIDatePickerNavModel, router: AnyRouter) {
        self.datePickerNavModel = navModel
        let initial = Self.resolvedInitialDate(for: navModel)
        self.selectedDate = initial
        self.displayedMonth = Calendar.current.startOfDay(for: initial)
        super.init(router: router)
    }

    func onSelectDate() {
        guard canCommit else { return }
        let localDate = calendar.startOfDay(for: selectedDate)
        datePickerNavModel.onDateSelected(localDate)

        Task { @MainActor [weak self] in
            self?.router.dismissModal()
        }
    }
}

// MARK: - Selectable window
extension DatePickerViewModel {

    /// Whole selectable range, honouring `minimumDate` / `maximumDate` and falling back to
    /// `allowFutureDates` for an open upper bound.
    var dateRange: ClosedRange<Date> {
        let bounds = Self.bounds(for: datePickerNavModel)
        return bounds.lower <= bounds.upper ? bounds.lower...bounds.upper : bounds.lower...bounds.lower
    }

    /// When the configured minimum date exceeds the maximum date, the selectable range is
    /// empty: the calendar is shown but interaction is disabled.
    var isSelectionDisabled: Bool {
        guard let lower = datePickerNavModel.minimumDate,
              let upper = datePickerNavModel.maximumDate
        else { return false }
        return lower > upper
    }

    /// True when the modal must render its own month grid rather than the system calendar.
    var usesWeekdayExclusions: Bool { !datePickerNavModel.disabledWeekdays.isEmpty }

    /// A day is selectable when it sits inside the window and is not an excluded weekday.
    /// Bounds are compared whole-day, so both boundary days are selectable.
    func isSelectable(_ date: Date) -> Bool {
        guard !isSelectionDisabled else { return false }
        let bounds = Self.bounds(for: datePickerNavModel)
        let day = calendar.startOfDay(for: date)
        guard day >= calendar.startOfDay(for: bounds.lower),
              day <= calendar.startOfDay(for: bounds.upper)
        else { return false }
        return !datePickerNavModel.disabledWeekdays.contains(calendar.component(.weekday, from: day))
    }

    /// Gates the Done button: the modal can never hand back an excluded or out-of-range day.
    var canCommit: Bool { isSelectable(selectedDate) }

    private static func bounds(
        for navModel: NavigationViewModel.SUIDatePickerNavModel
    ) -> (lower: Date, upper: Date) {
        let lower = navModel.minimumDate ?? .distantPast

        let upper: Date
        if let maxDate = navModel.maximumDate {
            upper = maxDate
        } else if navModel.allowFutureDates {
            upper = .distantFuture
        } else {
            upper = Calendar.current.startOfDay(for: Date())
        }
        return (lower, upper)
    }

    /// The day the modal opens on. With no exclusions this is the caller's `initialDate`,
    /// unchanged. Otherwise an excluded initial day (a Sunday "today", say) is nudged to the
    /// nearest allowed day so the calendar never opens on a day the user cannot confirm.
    private static func resolvedInitialDate(
        for navModel: NavigationViewModel.SUIDatePickerNavModel
    ) -> Date {
        guard !navModel.disabledWeekdays.isEmpty else { return navModel.initialDate }

        let calendar = Calendar.current
        let bounds = bounds(for: navModel)
        guard bounds.lower <= bounds.upper else { return navModel.initialDate }
        let lowerDay = calendar.startOfDay(for: bounds.lower)
        let upperDay = calendar.startOfDay(for: bounds.upper)

        func allows(_ date: Date) -> Bool {
            date >= lowerDay && date <= upperDay
                && !navModel.disabledWeekdays.contains(calendar.component(.weekday, from: date))
        }

        let start = calendar.startOfDay(for: navModel.initialDate)
        if allows(start) { return start }

        // A week in either direction covers every reachable weekday; forward first so the
        // nudge lands on the next working day rather than a past one.
        for offset in 1...7 {
            if let forward = calendar.date(byAdding: .day, value: offset, to: start), allows(forward) {
                return forward
            }
            if let backward = calendar.date(byAdding: .day, value: -offset, to: start), allows(backward) {
                return backward
            }
        }
        return start
    }
}

// MARK: - Month grid
extension DatePickerViewModel {

    /// Localised weekday headers, rotated to the calendar's first weekday.
    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let offset = calendar.firstWeekday - 1
        guard offset > 0, offset < symbols.count else { return symbols }
        return Array(symbols[offset...] + symbols[..<offset])
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.calendar = calendar
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    /// One entry per grid cell: `nil` for the leading blanks that push the first of the
    /// month under its weekday column, then every day of the month in order.
    var monthDays: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayCount = calendar.range(of: .day, in: .month, for: displayedMonth)?.count
        else { return [] }

        let firstDay = calendar.startOfDay(for: interval.start)
        let leadingBlanks = (calendar.component(.weekday, from: firstDay) - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for offset in 0..<dayCount {
            cells.append(calendar.date(byAdding: .day, value: offset, to: firstDay))
        }
        return cells
    }

    func isSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func select(_ date: Date) {
        guard isSelectable(date) else { return }
        selectedDate = calendar.startOfDay(for: date)
    }

    var canGoToPreviousMonth: Bool {
        guard let previous = month(offset: -1),
              let interval = calendar.dateInterval(of: .month, for: previous)
        else { return false }
        // `dateInterval` end is the first instant of the next month.
        let lastDay = calendar.startOfDay(for: interval.end.addingTimeInterval(-1))
        return lastDay >= calendar.startOfDay(for: Self.bounds(for: datePickerNavModel).lower)
    }

    var canGoToNextMonth: Bool {
        guard let next = month(offset: 1),
              let interval = calendar.dateInterval(of: .month, for: next)
        else { return false }
        let firstDay = calendar.startOfDay(for: interval.start)
        return firstDay <= calendar.startOfDay(for: Self.bounds(for: datePickerNavModel).upper)
    }

    func goToPreviousMonth() {
        guard canGoToPreviousMonth, let previous = month(offset: -1) else { return }
        displayedMonth = previous
    }

    func goToNextMonth() {
        guard canGoToNextMonth, let next = month(offset: 1) else { return }
        displayedMonth = next
    }

    private func month(offset: Int) -> Date? {
        calendar.date(byAdding: .month, value: offset, to: displayedMonth)
    }
}

//
//  CalendarGridView.swift
//  SwiftUIUtilities
//
//  Month grid used by `DatePickerView` when the caller excludes one or more weekdays.
//  The system graphical `DatePicker` only understands a contiguous min/max range, so a
//  repeating exclusion (e.g. "no Sundays") has to be drawn here: excluded and
//  out-of-window days render dimmed and do not respond to a tap.
//

import SwiftUI

struct CalendarGridView: View {

    @ObservedObject var viewModel: DatePickerViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            header
            weekdayHeader
            grid
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            monthButton(systemName: "chevron.left", isEnabled: viewModel.canGoToPreviousMonth) {
                viewModel.goToPreviousMonth()
            }
            Spacer(minLength: 8)
            Text(viewModel.monthTitle)
                .font(.system(size: 17, weight: .semibold))
            Spacer(minLength: 8)
            monthButton(systemName: "chevron.right", isEnabled: viewModel.canGoToNextMonth) {
                viewModel.goToNextMonth()
            }
        }
    }

    private func monthButton(systemName: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isEnabled ? ColorUtility.primaryColor : .secondary.opacity(0.4))
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(Array(viewModel.weekdaySymbols.enumerated()), id: \.offset) { item in
                Text(item.element)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Grid

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(viewModel.monthDays.enumerated()), id: \.offset) { item in
                if let date = item.element {
                    dayCell(for: date)
                } else {
                    Color.clear.frame(height: 40)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelectable = viewModel.isSelectable(date)
        let isSelected = viewModel.isSelected(date) && isSelectable

        return Button(action: { viewModel.select(date) }) {
            Text(dayNumber(for: date))
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(foregroundColor(isSelectable: isSelectable, isSelected: isSelected))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? ColorUtility.primaryColor : .clear)
                        .frame(width: 38, height: 38)
                )
                .overlay(
                    Circle()
                        .stroke(ColorUtility.primaryColor.opacity(0.5), lineWidth: 1)
                        .frame(width: 38, height: 38)
                        .opacity(viewModel.isToday(date) && !isSelected ? 1 : 0)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isSelectable)
        // An excluded day stays visible — greyed out and inert — so the calendar reads as
        // "not available" rather than as a missing day.
        .accessibilityLabel(accessibilityLabel(for: date, isSelectable: isSelectable))
    }

    private func foregroundColor(isSelectable: Bool, isSelected: Bool) -> Color {
        if isSelected { return ColorUtility.primaryColor.getDynamicTextColor }
        return isSelectable ? .primary : Color.secondary.opacity(0.35)
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func accessibilityLabel(for date: Date, isSelectable: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .full
        let day = formatter.string(from: date)
        return isSelectable ? day : "\(day), unavailable"
    }
}

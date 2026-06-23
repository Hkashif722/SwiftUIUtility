//
//  DatePickerViewModel.swift
//  SwiftUIUtilities
//
//  Reusable date-picker modal view model.
//

import Foundation
import SwiftfulRouting

final class DatePickerViewModel: RoutableViewModel {

    let datePickerNavModel: NavigationViewModel.SUIDatePickerNavModel

    @Published var selectedDate: Date

    init(navModel: NavigationViewModel.SUIDatePickerNavModel, router: AnyRouter) {
        self.datePickerNavModel = navModel
        self.selectedDate = navModel.initialDate
        super.init(router: router)
    }

    func onSelectDate() {
        let localDate = Calendar.current.startOfDay(for: selectedDate)
        datePickerNavModel.onDateSelected(localDate)

        Task { @MainActor [weak self] in
            self?.router.dismissModal()
        }
    }
}

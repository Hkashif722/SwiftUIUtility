//
//  TimePickerViewModel.swift
//  SwiftUIUtilities
//
//  Reusable time-picker modal view model.
//

import Foundation
import SwiftfulRouting

final class TimePickerViewModel: RoutableViewModel {

    let timePickerNavModel: NavigationViewModel.SUITimePickerNavModel

    @Published var selectedTime: Date

    init(navModel: NavigationViewModel.SUITimePickerNavModel, router: AnyRouter) {
        self.timePickerNavModel = navModel
        self.selectedTime = navModel.initialTime
        super.init(router: router)
    }

    func onSelectTime() {
        timePickerNavModel.onTimeSelected(selectedTime)

        Task { @MainActor [weak self] in
            self?.router.dismissModal()
        }
    }
}

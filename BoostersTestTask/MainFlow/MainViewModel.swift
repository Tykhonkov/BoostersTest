//
//  MainViewModel.swift
//  BoostersTestTask
//
//  Created by Elias on 01.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Combine
import Foundation

class MainViewModel: ObservableObject {
    
    var alarmTimeString: String  {
        return timeFormatter.string(from: alarmTime)
    }
    @Published var alarmTime: Date = Date()
    @Published private(set) var statusString: String = "Idle"
    
    private var disposables = Set<AnyCancellable>()

    var sleepTimerDurationsStrings: [String] {
        return sleepTimerDurations.enumerated().map { $0.offset == 0 ? "off" : String("\($0.element) min") }
    }
    private let sleepTimerDurations: [Int] = [0, 1, 5, 10, 15, 20]

    func timerDurationSelected(at row: Int) {
        //        sleepTimerDurations[row] handle  new sleep timer duration
    }
    
}

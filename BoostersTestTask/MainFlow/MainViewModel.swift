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
        return alarmTime.map { timeFormatter.string(from: $0) } ?? "not set"
    }
    var currentSleepTimerDurationString: String {
        return sleepTimerDurationsStrings[currentSleepTimerDurationIndex]
    }
    var sleepTimerDurationsStrings: [String] {
        return sleepTimerDurations.enumerated().map { $0.offset == 0 ? "off" : String("\($0.element) min") }
    }
    @Published var alarmTime: Date?
    @Published var isRecordingEnabled = true
    @Published private(set) var statusString: String = "Idle"

    private var currentSleepTimerDurationIndex: Int
    private var disposables = Set<AnyCancellable>()

    private let sleepTimerDurations: [Int] = [0, 1, 5, 10, 15, 20]
    private let audioSession: AudioSession
    
    init(audioSession: AudioSession = AudioSession()) {
        self.audioSession = audioSession
        currentSleepTimerDurationIndex = sleepTimerDurations.count - 1
    }

    func timerDurationSelected(at row: Int) {
        currentSleepTimerDurationIndex = row
    }
    
    func stateSwitcherButtonAction() {
        
    }
    
}

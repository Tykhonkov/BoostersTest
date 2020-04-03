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
        return sleepTimerDurations
            .enumerated()
            .map { $0.offset == 0 ? "off" : String("\($0.element) min") }
    }
    @Published var isControlsDissabled: Bool = false
    @Published var alarmTime: Date?
    @Published var isRecordingEnabled: Bool = true
    @Published private(set) var statusString: String = "Idle"
    @Published private(set) var stateButtonSwitcherTitle: String = "Play"

    private var currentSleepTimerDurationIndex: Int
    private var disposables = Set<AnyCancellable>()

    private let sleepTimerDurations: [Int]
    private let workflowCoordinator: BoostersWorkflowCoordinator
    
    init(workflowCoordinator: BoostersWorkflowCoordinator,
         sleepTimerDurations: [Int] = [0, 1, 5, 10, 15, 20]) {
        self.sleepTimerDurations = sleepTimerDurations
        self.workflowCoordinator = workflowCoordinator
        currentSleepTimerDurationIndex = sleepTimerDurations.count - 1
       
        setupBindings()
    }

    func timerDurationSelected(at row: Int) {
        currentSleepTimerDurationIndex = row
        workflowCoordinator.set(duration: Double(sleepTimerDurations[row] * 60))
    }
    
    func stateSwitcherButtonAction() {
        workflowCoordinator.handleInput(.stateButtonAction)
    }
    
    private func setupBindings() {
        workflowCoordinator.$state.sink { [unowned self] newState in
            self.statusString = self.stateTitle(for: newState)
            self.stateButtonSwitcherTitle = self.stateSwitcherButtonTitle(for: newState)
            self.isControlsDissabled = self.isControlsDissabled(for: newState)
        }
        .store(in: &disposables)
        
        $alarmTime
            .dropFirst()
            .sink { [unowned self] date in
                date.map { self.workflowCoordinator.set(alarmDate: $0) }
            }
        .store(in: &disposables)
        $isRecordingEnabled
                   .dropFirst()
                   .sink { [unowned self] isEnabled in
                       self.workflowCoordinator.set(recording: isEnabled)
                   }
               .store(in: &disposables)
        
    }
    
    private func isControlsDissabled(for state: BoostersWorkflowCoordinator.BoostersState) -> Bool {
        switch state {
        case .idle, .initial:
            return false
        default:
            return true
        }
    }
    
    private func stateTitle(for state: BoostersWorkflowCoordinator.BoostersState) -> String {
        switch state {
        case .idle, .initial:
            return "Idle"
        case .playingPaused:
            return "Playing Paused"
        case .recordingPaused:
            return "Recording Paused"
        case .playing:
            return "Playing"
        case .recording:
            return "Recording"
        case .alarm:
            return "Alarm"
        }
    }
    
    private func stateSwitcherButtonTitle(for state: BoostersWorkflowCoordinator.BoostersState) -> String {
        switch state {
        case .idle, .initial, .playingPaused:
            return "Play"
        case .recordingPaused:
            return "Record"
        case .playing, .recording:
            return "Pause"
        case .alarm:
            return "Stop"
        }
    }
    
}

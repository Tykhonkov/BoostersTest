//
//  BoostersWorkflowCoordinator.swift
//  BoostersTestTask
//
//  Created by Elias on 02.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Combine
import Foundation

private let dayInSeconds: TimeInterval = 60 * 60 * 24
private let alarmNotificationIdentifier: String = "alarm"

class BoostersWorkflowCoordinator {
    
    enum BoostersState {
        case initial, idle, playing, playingPaused, recording, recordingPaused, alarm
    }
    
    enum BoostersStateInputs {
        case stateButtonAction, finishedPlayingSound, receivedAlarmNotification, interruption(interruption: AudioSession.Interruption)
    }
    
    struct BoostersCoordinatorConfiguration {
        var audioSession: AudioSession
        var audioPlayer: BoostersAudioPlayer
        var audioRecorder: BoostersAudioRecorder
        var notificationsManager: NotificationsManager
        var soundFileURL: URL
        var alarmSoundName: String
        var alarmSoundURL: URL
        var sleepSoundDuratioon: TimeInterval
        var shouldPlayNatureSound: Bool
        var isRecordingEnabled: Bool
    }
    
    @Published private(set) var state: BoostersState = .initial
    
    private var sleepSoundDuratioon: TimeInterval
    private var isRecordingEnabled: Bool
    
    private let notificationsManager: NotificationsManager
    
    private let audioSession: AudioSession
    private let audioPlayer: BoostersAudioPlayer
    private let audioRecorder: BoostersAudioRecorder
    private let soundFileURL: URL
    private let alarmSoundName: String
    private let alarmSoundURL: URL

    private let alarmNotificationId: String = "alarm"
    private var disposables: Set<AnyCancellable> = Set<AnyCancellable>()
    
    init(configuration: BoostersCoordinatorConfiguration) {
        self.audioSession = configuration.audioSession
        self.audioPlayer = configuration.audioPlayer
        self.audioRecorder = configuration.audioRecorder
        self.soundFileURL = configuration.soundFileURL
        self.alarmSoundName = configuration.alarmSoundName
        self.sleepSoundDuratioon = configuration.sleepSoundDuratioon
        self.isRecordingEnabled = configuration.isRecordingEnabled
        self.notificationsManager = configuration.notificationsManager
        self.alarmSoundURL = configuration.alarmSoundURL
        
        notificationsManager.$receivedNotification
            .sink { [unowned self] notification in
                guard notification != nil else { return }
                self.handleInput(.receivedAlarmNotification)
            }
        .store(in: &disposables)
        audioSession.$interruption
            .sink { [unowned self] interruption in
                guard let interruption = interruption else { return }
                self.handleInput(BoostersWorkflowCoordinator.BoostersStateInputs.interruption(interruption: interruption))
            }
        .store(in: &disposables)
        initialPreparations()
    }
    
    /// Only possible to set while in initial or idle state
    func set(duration: TimeInterval) {
        self.sleepSoundDuratioon = duration
    }
    
    func set(alarmDate: Date) {
        notificationsManager.requestNotificationsAuthorizationIfNeeded()
            .sink(receiveCompletion: { result in
                switch result {
                case.finished:
                    var alarmDate = alarmDate
                    if alarmDate.timeIntervalSinceNow < 0 {
                        alarmDate = alarmDate.addingTimeInterval(dayInSeconds)
                    }
                    self.notificationsManager.removePendingNotification(with: alarmNotificationIdentifier)
                    self.notificationsManager.scheduleNotification(
                        at: alarmDate,
                        soundName: self.alarmSoundName,
                        identifier: alarmNotificationIdentifier,
                        title: "Alarm",
                        subtitle: "Wake up! 🌞") { _ in
                            
                    }
                case .failure: break
                    // error handling
                }
            }, receiveValue: { _ in })
            .store(in: &disposables)
    }
    
    /// Only possible to set while in initial or idle state
    func set(recording enabled: Bool) {
        isRecordingEnabled = enabled
    }
    
    func handleInput(_ input: BoostersStateInputs) {
        print("Current state: \(state)")
        print("Input: \(input)")
        switch (state, input) {
        case (.initial, .stateButtonAction):
            initialPreparations()
        case (.idle, .stateButtonAction) where self.sleepSoundDuratioon == 0 && isRecordingEnabled:
            record()
        case (.idle, .stateButtonAction) where self.sleepSoundDuratioon == 0 && !isRecordingEnabled:
            break
        case (.idle, .stateButtonAction):
            try? playSoundInLoop(contentsOf: soundFileURL, with: sleepSoundDuratioon)
            self.state = .playing
        case (.playing, .stateButtonAction):
            pausePlaying()
            state = .playingPaused
        case (.playingPaused, .stateButtonAction):
            resumePlaying()
            state = .playing
        case (.playing, .finishedPlayingSound) where isRecordingEnabled:
            record()
        case (.playing, .finishedPlayingSound) where !isRecordingEnabled:
            state = .idle
        case (.recording, .stateButtonAction):
            pauseRecording()
            state = .recordingPaused
        case (.recordingPaused, .stateButtonAction):
            resumeRecording()
            state = .recording
        case (.alarm, .stateButtonAction):
            stopPlaying()
            state = .idle
        case (.recording, .receivedAlarmNotification),
             (.playing, .receivedAlarmNotification),
             (.recordingPaused, .receivedAlarmNotification),
             (.playingPaused, .receivedAlarmNotification),
             (.idle, .receivedAlarmNotification):
            stopRecording()
            stopPlaying()
            state = .alarm
            try? playSoundInLoop(contentsOf: alarmSoundURL, with: TimeInterval.greatestFiniteMagnitude)
        case (.recording, .interruption(let interruption)):
            interruption == .ended ? resumeRecording() : pauseRecording()
        case (.playing, .interruption(let interruption)):
            if interruption == .ended  {
                resumePlaying()
            }
        default:
            break
        }
        print("Result state: \(state)")
    }
    
   private func initialPreparations() {
        do {
            try audioSession.prepare()
            audioSession.requestRecordsPermissionIfNeeded()
                .sink(receiveCompletion: { [unowned self] completion in
                    switch completion {
                    case .failure:
                        break
                    case .finished:
                        self.state = .idle
                    }
                }, receiveValue: { _ in
                        
                }).store(in: &disposables)
        } catch {
            print(error)
        }
    }
    
    private func playSoundInLoop(contentsOf url: URL, with duration: TimeInterval) throws  {
        try audioPlayer.playInLoop(contentsOf: url, with: duration) { [unowned self] in
            self.handleInput(.finishedPlayingSound)
        }
    }

    private func pausePlaying() {
        audioPlayer.pause()
    }
    
    private func stopPlaying() {
        audioPlayer.stop()
    }

    private func resumePlaying() {
        audioPlayer.resume()
    }

    private func record() {
        let fileName = ("\(Date().timeIntervalSince1970)_recording.m4a")
        let url = FileManager.getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try audioRecorder.startRecording(in: url)
            state = .recording
        } catch {
            print(error)
        }
    }

    private func pauseRecording() {
        audioRecorder.pause()
    }

    private func resumeRecording() {
        audioRecorder.resume()
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording()
    }
    
}

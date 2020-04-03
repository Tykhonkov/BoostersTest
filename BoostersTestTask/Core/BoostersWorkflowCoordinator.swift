//
//  BoostersWorkflowCoordinator.swift
//  BoostersTestTask
//
//  Created by Elias on 02.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import Combine
import Foundation

class BoostersWorkflowCoordinator {
    
    enum BoostersState {
        case initial, idle, playing, playingPaused, recording, recordingPaused, alarm
    }
    
    enum BoostersStateInputs {
        case stateButtonAction, finishedPlayingSound, recievedLocalNotification
    }
    
    struct BoostersCoordinatorConfiguration {
        var audioSession: AudioSession
        var audioPlayer: BoostersAudioPlayer
        var audioRecorder: BoostersAudioRecorder
        var soundFileURL: URL
        var alarmSoundName: String
        var sleepSoundDuratioon: TimeInterval
        var shouldPlayNatureSound: Bool
        var shouldRecord: Bool
    }
    
    @Published private(set) var state: BoostersState = .initial
    
    private var sleepSoundDuratioon: TimeInterval
    private var shouldRecord: Bool
    
    private let audioSession: AudioSession
    private let audioPlayer: BoostersAudioPlayer
    private let audioRecorder: BoostersAudioRecorder
    private var soundFileURL: URL
    private let alarmSoundName: String
    
    private var disposables = Set<AnyCancellable>()
    
    init(configuration: BoostersCoordinatorConfiguration) {
        self.audioSession = configuration.audioSession
        self.audioPlayer = configuration.audioPlayer
        self.audioRecorder = configuration.audioRecorder
        self.soundFileURL = configuration.soundFileURL
        self.alarmSoundName = configuration.alarmSoundName
        self.sleepSoundDuratioon = configuration.sleepSoundDuratioon
        self.shouldRecord = configuration.shouldRecord
    }
    
    /// Only possible to set while in initial or idle state
    func set(duration: TimeInterval) {
        self.sleepSoundDuratioon = duration
    }
    
    /// Only possible to set while in initial or idle state
    func set(alarmDate: Date) {
        
    }
    
    /// Only possible to set while in initial or idle state
    func set(recording enabled: Bool) {
        shouldRecord = enabled
    }
    
    func handleInput(_ input: BoostersStateInputs) {
        print("Current state: \(state)")
        print("Input: \(input)")
        switch (state, input) {
        case (.initial, .stateButtonAction):
            initialPreparations()
        case (.idle, .stateButtonAction) where self.sleepSoundDuratioon == 0 && shouldRecord:
            record()
        case (.idle, .stateButtonAction) where self.sleepSoundDuratioon == 0 && !shouldRecord:
            break // wait for alarm
        case (.idle, .stateButtonAction):
            self.playSoundInLoop(contentsOf: soundFileURL, with: sleepSoundDuratioon)

        case (.playing, .stateButtonAction):
            pauseSound()
            state = .playingPaused
        case (.playingPaused, .stateButtonAction):
            resumePlaying()
            state = .playing
        case (.playing, .finishedPlayingSound) where shouldRecord:
            record()
        case (.playing, .finishedPlayingSound) where !shouldRecord:
                    state = .idle
            break
        case (.recording, .stateButtonAction):
            pauseRecording()
            state = .recordingPaused
        case (.recordingPaused, .stateButtonAction):
            resumeRecording()
            state = .recording
        case (.alarm, .stateButtonAction): break
            
        default:
            print("State not handled")
        }
        print("Result state: \(state)")
    }
    
    func initialPreparations() {
        do {
            try audioSession.prepare()
            audioSession.requestRecordsPermissionIfNeeded()
                .sink(receiveCompletion: { [unowned self] completion in
                    switch completion {
                    case .failure:
                        break
                    case .finished:
                        self.state = .idle
                        self.handleInput(.stateButtonAction)
                    }
                    }, receiveValue: { _ in
                        
                }).store(in: &disposables)
        } catch {
            print(error)
        }
    }
    
    private func playSoundInLoop(contentsOf url: URL, with duration: TimeInterval) {
        do {
            try audioPlayer.playInLoop(contentsOf: url, with: duration) { [unowned self] in
                self.handleInput(.finishedPlayingSound)
            }
            self.state = .playing
        } catch {
            print(error)
        }
    }

    private func pauseSound() {
        audioPlayer.pause()
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

    private  func resumeRecording() {
        audioRecorder.resume()
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording()
    }
    
}

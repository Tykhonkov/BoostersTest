//
//  AudioManager.swift
//  BoostersTestTask
//
//  Created by Elias on 02.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import AVFoundation
import Combine


class AudioSession: NSObject {
    
    enum Interruption {
        case began, ended
    }
    
    @Published var interruption: Interruption!
    private let audioSession: AVAudioSession
    
    init(audioSession: AVAudioSession = AVAudioSession.sharedInstance()) {
        self.audioSession = audioSession
        
        super.init()
        
        subscribeForAudioSessionInterruptions()
    }
    
    func prepare() throws {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            throw BoostersError.audioSessionError(string: error.localizedDescription)
        }
    }
    
    func requestRecordsPermissionIfNeeded() -> AnyPublisher<Void,BoostersError> {
        return Future { [unowned self] promise in
            switch self.audioSession.recordPermission {
            case .undetermined:
                self.audioSession.requestRecordPermission() { allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            promise(.success(()))
                        } else {
                            promise(.failure(BoostersError.microphoneUsagePermissionError))
                        }
                    }
                }
            case .granted:
                promise(.success(()))
            case .denied:
                promise(.failure(BoostersError.microphoneUsagePermissionError))
            @unknown default:
                fatalError("undefined case")
            }
        }
        .eraseToAnyPublisher()
    }
    
    func subscribeForAudioSessionInterruptions() {
        // Get the default notification center instance.
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
    }

   @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        switch type {
        case .began:
            interruption = .began
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                interruption = .ended
            }
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

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
    
    enum AudioSessionState: String {
        case idle
        case playing
        case recording
        case paused
    }
    
    @Published private(set) var state: AudioSessionState = .idle
    private let audioSession: AVAudioSession
    
    init(
        audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    ) {
        self.audioSession = audioSession
        
        super.init()
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
                            promise(.failure(BoostersError.permissionDeniedError))
                        }
                    }
                }
            case .granted:
                promise(.success(()))
            case .denied:
                promise(.failure(BoostersError.permissionDeniedError))
            @unknown default:
                fatalError("undefined case")
            }
        }
        .eraseToAnyPublisher()
    }
    
}

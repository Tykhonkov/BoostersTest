//
//  BoostersAudioRecorder.swift
//  BoostersTestTask
//
//  Created by Elias on 03.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import AVFoundation

class BoostersAudioRecorder: NSObject {
    
    private var audioRecorder: AVAudioRecorder?
    private let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    func startRecording(in url: URL) throws {
        audioRecorder = try AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func pause() {
        audioRecorder?.pause()
    }
    
    func resume() {
        audioRecorder?.record()
    }
    
}

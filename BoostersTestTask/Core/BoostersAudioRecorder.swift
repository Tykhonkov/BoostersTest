//
//  BoostersAudioRecorder.swift
//  BoostersTestTask
//
//  Created by Elias on 03.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import AVFoundation

class BoostersAudioRecorder: NSObject {

    var audioRecorder: AVAudioRecorder!
    
    func startRecording(in url: URL) {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            do {
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                finishRecording(success: false)
            }
        }

    func finishRecording(success: Bool) {
            audioRecorder.stop()
            audioRecorder = nil
    }
    
    func pause() {
        audioRecorder.pause()
    }
    
    func resume() {
        audioRecorder.record()
    }
    
}

extension BoostersAudioRecorder: AVAudioRecorderDelegate {
    
}


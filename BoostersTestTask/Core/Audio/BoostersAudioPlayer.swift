//
//  BoostersAudioPlayer.swift
//  BoostersTestTask
//
//  Created by Elias on 03.04.2020.
//  Copyright © 2020 Elias. All rights reserved.
//

import AVFoundation

class BoostersAudioPlayer {
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private var timerScheduledAtDate: Date?
    
    private var remainingPlayingDuration: TimeInterval = 0.0
    private var playingFinished: (() -> Void)?
    
    func playInLoop(contentsOf url: URL, with duration: TimeInterval, completion: @escaping () -> Void) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
        
        remainingPlayingDuration = duration
        timerScheduledAtDate = Date()
        playingFinished = completion
        
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [unowned self] timer in
            self.audioPlayer?.pause()
            timer.invalidate()
            self.playingFinished?()
        }
    }
 
    func pause() {
        guard let audioPlayer = audioPlayer else { return }
        timer?.invalidate()
        timer = nil
        audioPlayer.pause()
        remainingPlayingDuration = remainingPlayingDuration - (timerScheduledAtDate?.timeIntervalSinceNow ?? 0)
    }
    
    func resume() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.play()
        timerScheduledAtDate = Date()
        scheduleTimer(duration: remainingPlayingDuration)
    }
    
    func stop() {
        timer?.invalidate()
        audioPlayer?.stop()
    }
    
    private func scheduleTimer(duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: remainingPlayingDuration, repeats: false) { [unowned self] _ in
            self.stop()
            self.playingFinished?()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
}

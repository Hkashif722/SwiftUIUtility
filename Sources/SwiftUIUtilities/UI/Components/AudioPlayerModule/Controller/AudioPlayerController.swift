//
//  AudioPlayerController.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import AVFoundation
import Combine

/// Controller responsible for managing AVPlayer and audio playback logic.
public class AudioPlayerController {
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    public var cancellables = Set<AnyCancellable>()
    
    /// Publisher to expose player's play/pause status.
    public var isPlayingPublisher = PassthroughSubject<Bool, Never>()
    
    /// Publisher to track audio progress.
    public var currentTimePublisher = PassthroughSubject<Double, Never>()
    public var durationPublisher = PassthroughSubject<Double, Never>()

    public init() {}

    /// Configure audio session for playback
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    /// Setup audio interruption handling
    private func setupAudioInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            if player?.timeControlStatus == .playing {
                player?.pause()
                isPlayingPublisher.send(false)
            }
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    player?.play()
                    isPlayingPublisher.send(true)
                }
            }
        @unknown default:
            break
        }
    }

    /// Initializes the player with a given remote or local URL.
    public func setupPlayer(with url: URL) {
        configureAudioSession()
        setupAudioInterruptionHandling()
        
        if player == nil {
            player = AVPlayer(url: url)
            addPeriodicTimeObserver()
            setupPlayerItemObserver()
        }
        self.addPlayerDidReachedToEndNotification()
    }
    
    /// Setup player item observer for duration and status
    private func setupPlayerItemObserver() {
        guard let playerItem = player?.currentItem else { return }
        
        playerItem.publisher(for: \.status)
            .sink { [weak self] status in
                if status == .readyToPlay {
                    let duration = CMTimeGetSeconds(playerItem.duration)
                    if duration.isFinite {
                        DispatchQueue.main.async {
                            self?.durationPublisher.send(duration)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Add a time observer to track the player's progress.
    private func addPeriodicTimeObserver() {
        guard let player = player else { return }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            self?.currentTimePublisher.send(currentTime)
        }
    }

    /// Toggle play/pause functionality.
    public func togglePlayback() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
            DispatchQueue.main.async {
                self.isPlayingPublisher.send(false)
            }
        } else {
            player.play()
            DispatchQueue.main.async {
                self.isPlayingPublisher.send(true)
            }
        }
    }
    
    /// Seek the player to a specific time.
    public func seek(to time: Double) {
        guard let player = player else { return }
        let timeScale = player.currentItem?.duration.timescale ?? CMTimeScale(NSEC_PER_SEC)
        let seekTime = CMTime(seconds: time, preferredTimescale: timeScale)
        player.seek(to: seekTime)
    }
    
    /// Skip forward by 10 seconds.
    public func skipForward() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 10
        seek(to: newTime)
    }
    
    /// Skip backward by 10 seconds.
    public func skipBackward() {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = max(currentTime - 10, 0)  // Don't go below 0
        seek(to: newTime)
    }
    
    /// Clean up the time observer when no longer needed.
    public func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    /// Notify player completed playing
    private func addPlayerDidReachedToEndNotification() {
        // Observe when the player reaches the end of playback
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }
    
    /// Stop playback and reset when audio finishes playing
    @objc private func playerDidFinishPlaying() {
        // Notify listeners that playback has stopped (audio has finished)
        isPlayingPublisher.send(false)
        player?.seek(to: .zero)  // Reset the player to the beginning
    }
    
    /// Clean up the audio resources and stop playback
    public func cleanupPlayer() {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self)
        cancellables.removeAll()
        
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}


extension AudioPlayerController {
    public func setTimeObserverEnabled(_ enabled: Bool) {
        if enabled {
            // Resume observer if not already active
            if timeObserverToken == nil {
                addPeriodicTimeObserver()
            }
        } else {
            // Pause observer temporarily
            removeTimeObserver()
        }
    }
}

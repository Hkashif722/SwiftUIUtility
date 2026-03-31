//
//  AudioPlayerViewModel.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import SwiftUI
import Combine

/// ViewModel for managing audio playback and exposing state to the view.
public class AudioPlayerViewModel: ObservableObject {
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var waveformHeights: [CGFloat] = Array(repeating: 10, count: 30)
    @Published public var isLoading: Bool = true
    @Published public var isSeeking: Bool = false
    @Published public var errorMessage: String? = nil
    
    private var controller = AudioPlayerController() // Audio controller
    private var cancellables = Set<AnyCancellable>()
    private var animationTimer: Timer?
    
    public var audioController: AudioPlayerController {
        return controller
    }

    public init() {
        setupBindings()
    }
    
    public init(_ audioURL: URL) {
        setupBindings()
        setupAudioPlayer(with: audioURL)
    }
    
    /// Set up the audio player asynchronously.
    public func setupAudioPlayer(with url: URL) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.controller.setupPlayer(with: url)
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    /// Toggle play/pause state.
    public func togglePlayback() {
        controller.togglePlayback()
        isPlaying ? stopWaveformAnimation() : startWaveformAnimation()
    }
    
    /// Start waveform animation.
    private func startWaveformAnimation() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.waveformHeights = self?.waveformHeights.map { _ in CGFloat.random(in: 5...30) } ?? []
        }
    }
    
    /// Stop waveform animation.
    private func stopWaveformAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /// Update your existing seek method
    public func seek(to time: Double) {
        isSeeking = true
        controller.seek(to: time)
        
        // Reset isSeeking after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isSeeking = false
        }
    }
    
    /// Skip forward by 10 seconds.
    public func skipForward() {
        controller.skipForward()
    }
    
    /// Skip backward by 10 seconds.
    public func skipBackward() {
        controller.skipBackward()
    }
    
    /// Set up Combine bindings to synchronize state with the controller.
    private func setupBindings() {
        controller.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                self?.isPlaying = isPlaying
                isPlaying ? self?.startWaveformAnimation() : self?.stopWaveformAnimation()
            }
            .store(in: &cancellables)
        
        controller.currentTimePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentTime in
                guard let self = self, !self.isSeeking else { return }
                self.currentTime = currentTime
            }
            .store(in: &cancellables)
        
        controller.durationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.duration = duration
            }
            .store(in: &cancellables)
    }
    
    /// Cleanup resources.
    public func cleanupAudioResources() {
        controller.cleanupPlayer()
        cancellables.removeAll()
        stopWaveformAnimation()
    }

    deinit {
        cleanupAudioResources()
        print("AudioPlayerViewModel deallocated")
    }
}


extension AudioPlayerViewModel {
    public func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

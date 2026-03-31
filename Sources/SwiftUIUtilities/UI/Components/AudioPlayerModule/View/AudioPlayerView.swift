//
//  SwiftUIView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 20/10/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//
import SwiftUI

public struct AudioPlayerView: View {
    @StateObject private var viewModel = AudioPlayerViewModel()  // ViewModel instance
    var audioURL: URL  // Accepts the URL of the audio file
    
    public init(audioURL: URL) {
        self.audioURL = audioURL
    }

    public var body: some View {
        VStack {
            if !viewModel.isLoading && viewModel.duration > 0.0 {
                playerContentView
            } else {
                loadingView
            }
        }
        .padding()
        .onAppear {
            viewModel.setupAudioPlayer(with: audioURL)  // Set up player with remote or local URL
        }
        .onDisappear {
            viewModel.cleanupAudioResources()  // Cleanup audio resources when view disappears
        }
    }

    // MARK: - Computed Views

    /// Loading view displayed while the audio is being loaded
    private var loadingView: some View {
        ProgressView("Loading audio...")
            .progressViewStyle(CircularProgressViewStyle())
    }

    /// Main content view for the audio player
    private var playerContentView: some View {
        VStack {
            playControls
            audioProgress
            timeLabels
            playbackControls
        }
        .padding()
    }

    /// Play/Pause Button and Waveform visualization
    private var playControls: some View {
        HStack(spacing: 4) {
            SwiftUIUtility.PlayerButtonView(isPlaying: $viewModel.isPlaying) {
                viewModel.togglePlayback()
            }
            WaveformView(waveformHeights: $viewModel.waveformHeights)
        }
        .padding(.top, 10)
    }

    /// Audio progress bar (slider) to seek audio time
    private var audioProgress: some View {
        AudioProgressView(
            currentTime: $viewModel.currentTime,
            duration: viewModel.duration
        ) { newTime in
            viewModel.seek(to: newTime)
        }
    }

    /// Displays current time and duration labels
    private var timeLabels: some View {
        AudioTimeLabels(
            currentTime: viewModel.currentTime,
            duration: viewModel.duration
        )
    }

    /// Forward and Backward playback control buttons
    private var playbackControls: some View {
        PlaybackControlsView(
            onSkipBackward: viewModel.skipBackward,
            onSkipForward: viewModel.skipForward
        )
    }
}

#Preview {
    AudioPlayerView(
        audioURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")!  // Example URL
    )
}

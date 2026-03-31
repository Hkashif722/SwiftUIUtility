//
//  AudioMediaPlayerView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 27/12/24.
//  Copyright © 2024 EnthrallTech. All rights reserved.
//

import SwiftUI
import SwiftfulRouting

public struct AudioMediaPlayerView: View {
    
    let audioPlayerNavModel: NavigationViewModel.AudioPlayerNavModel
    let router: AnyRouter
    
    @StateObject private var viewModel: AudioPlayerViewModel
    
    public init(_ navModel: NavigationViewModel.AudioPlayerNavModel, router: AnyRouter) {
        self.audioPlayerNavModel = navModel
        self._viewModel = StateObject(wrappedValue: AudioPlayerViewModel(navModel.audioURL))
        self.router = router
    }
    
    public var body: some View {
        VStack {
            switch viewModel.isLoading {
            case true:
                ProgressView("Loading...")
            case false:
                playerView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.black))
    }
    
    private var playerView: some View {
        Group {
            HStack(spacing: 2) {
                ForEach(viewModel.waveformHeights.indices, id: \.self) { index in
                    Capsule()
                        .frame(width: 4, height: viewModel.waveformHeights[index])
                        .foregroundColor(viewModel.isPlaying ? ColorUtility.primaryColor : .gray.opacity(0.5))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.waveformHeights)
            .frame(height: 35)
            
            audioTitle
            audioProgressBarView
            playbackControlView
        }
    }
    
    private var audioTitle: some View {
        Text("Now Playing \(audioPlayerNavModel.audioTitle ?? "")")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
    }
    
    private var audioProgressBarView: some View {
        VStack {
            Slider(
                value: $viewModel.currentTime,
                in: 0...max(viewModel.duration, 0.1),
                onEditingChanged: { isEditing in
                    viewModel.isSeeking = isEditing
                    if isEditing {
                        viewModel.audioController.setTimeObserverEnabled(false)
                    } else {
                        viewModel.seek(to: viewModel.currentTime)
                        viewModel.audioController.setTimeObserverEnabled(true)
                    }
                }
            )
            .tint(ColorUtility.primaryColor)
            .disabled(viewModel.duration <= 0)
            
            HStack {
                Text(viewModel.formattedTime(viewModel.currentTime))
                    .font(.caption)
                Spacer()
                Text(viewModel.formattedTime(viewModel.duration))
                    .font(.caption)
            }
        }
        .foregroundStyle(.white)
    }
    
    private var playbackControlView: some View {
        HStack(spacing: 40) {
            Button(action: { viewModel.skipBackward() }) {
                Image(systemName: "gobackward.10")
                    .font(.title)
            }
            
            Button(action: { viewModel.togglePlayback() }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(ColorUtility.primaryColor)
            }
            
            Button(action: { viewModel.skipForward() }) {
                Image(systemName: "goforward.10")
                    .font(.title)
            }
        }
        .foregroundStyle(ColorUtility.secondaryColor)
        .padding()
        .onDisappear {
            viewModel.cleanupAudioResources()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @Environment(\.router) var router
    let url = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/Fanfare60.wav")!
    let model = NavigationViewModel.AudioPlayerNavModel(audioURL: url, audioTitle: "")
    return AudioMediaPlayerView(model, router: router)
}

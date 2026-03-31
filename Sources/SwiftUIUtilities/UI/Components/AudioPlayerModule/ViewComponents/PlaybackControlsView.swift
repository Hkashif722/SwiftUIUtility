//
//  PlaybackControlsView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import SwiftUI

struct PlaybackControlsView: View {
    let onSkipBackward: () -> Void
    let onSkipForward: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onSkipBackward) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 30))
            }

            Button(action: onSkipForward) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 30))
            }
        }
    }
}

#Preview {
    PlaybackControlsView(onSkipBackward: {}, onSkipForward: {})
}

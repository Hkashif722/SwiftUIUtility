//
//  AudioTimeLabels.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import SwiftUI

struct AudioTimeLabels: View {
    let currentTime: Double
    let duration: Double

    var body: some View {
        HStack {
            Text(formatTime(currentTime))
            Spacer()
            Text(formatTime(duration))
        }
    }

    /// Formats time into mm:ss format.
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


#Preview {
    AudioTimeLabels(currentTime: 2.0, duration: 5)
}

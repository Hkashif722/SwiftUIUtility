//
//  WaveformView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//

import SwiftUI

/// A view that simulates waveform visualization.
struct WaveformView: View {
    @Binding var waveformHeights: [CGFloat]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<waveformHeights.count, id: \.self) { index in
                Capsule()
                    .fill(Color.red)
                    .frame(width: 5, height: waveformHeights[index])
            }
        }
    }
}

#Preview {
    @State var waveformHeights: [CGFloat] = Array(repeating: 10, count: 30)
    return WaveformView(waveformHeights: $waveformHeights)
}

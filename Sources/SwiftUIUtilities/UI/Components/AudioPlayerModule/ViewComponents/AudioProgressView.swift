//
//  AudioProgressView.swift
//  SwiftUIUtilities
//
//  Created by Kashif Hussain on 30/03/26.
//


import SwiftUI

struct AudioProgressView: View {
    @Binding var currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void

    var body: some View {
        Slider(value: $currentTime, in: 0...duration, onEditingChanged: { isEditing in
            if !isEditing {
                onSeek(currentTime)  // Call when seeking finishes
            }
        })
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var currentTime:Double = 2.0
    return AudioProgressView(currentTime: $currentTime, duration: 5) { duration in
        print(duration)
    }
}

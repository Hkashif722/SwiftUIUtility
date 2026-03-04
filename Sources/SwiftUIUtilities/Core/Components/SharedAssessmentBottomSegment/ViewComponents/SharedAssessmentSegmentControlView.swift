//
//  SharedAssessmentSegmentControlView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 08/10/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import SwiftUI

struct SharedAssessmentSegmentControlView<Content: View>: View {
    
    let content: (Int) -> Content
    let initialIndex: Int
    let totalCount: Int
    var onBackTapped: (() -> Void)?
    var onForwardTapped: (() -> Void)?
    var onIndexChanged: ((Int) -> Void)?
    
    @State private var currentIndex: Int
    
    init(
        initialIndex: Int = 0,
        totalCount: Int,
        onBackTapped: (() -> Void)? = nil,
        onForwardTapped: (() -> Void)? = nil,
        onIndexChanged: ((Int) -> Void)? = nil,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.initialIndex = initialIndex
        self.totalCount = totalCount
        self.onBackTapped = onBackTapped
        self.onForwardTapped = onForwardTapped
        self.onIndexChanged = onIndexChanged
        self.content = content
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            
            SwiftUIUtility.RoundMenuButton(
                image: .system(name: "chevron.left"),
                buttonSize: 40,
                foregroundColor: ColorUtility.secondaryColor.getDynamicTextColor,
                backgroundColor: ColorUtility.secondaryColor,
                action: handleBackTapped
            )
            .disabledWithOpacityPkg(isBackDisabled)
            
            // Content - Pass current index
            content(currentIndex)
                .frame(maxWidth: .infinity)
        
            
            SwiftUIUtility.RoundMenuButton(
                image: .system(name: "chevron.right"),
                buttonSize: 40,
                foregroundColor: ColorUtility.secondaryColor.getDynamicTextColor,
                backgroundColor: ColorUtility.secondaryColor,
                action: handleForwardTapped
            )
            .disabledWithOpacityPkg(isForwardDisabled)
        }
        .onChange(of: initialIndex) { newIndex in
            // Sync external changes to internal state
            if newIndex != currentIndex {
                currentIndex = newIndex
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isBackDisabled: Bool {
        currentIndex <= 0
    }
    
    private var isForwardDisabled: Bool {
        currentIndex >= totalCount - 1
    }
    
    // MARK: - Actions
    
    private func handleBackTapped() {
        guard currentIndex > 0 else { return }
        onBackTapped?()
        currentIndex -= 1
        onIndexChanged?(currentIndex)
    }
    
    private func handleForwardTapped() {
        guard currentIndex < totalCount - 1 else { return }
        onForwardTapped?()
        currentIndex += 1
        onIndexChanged?(currentIndex)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var currentIndex = 0
        let segmentDataModel = SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel.sampleList
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Current Segment: \(currentIndex + 1) of \(segmentDataModel.count)")
                    .font(.headline)
                
                // Example 1: With Segment List View
                SharedAssessmentSegmentControlView(
                    initialIndex: currentIndex,
                    totalCount: segmentDataModel.count,
                    onIndexChanged: { index in
                        currentIndex = index
                        print("Index changed to: \(index)")
                    }
                ) { selectedIndex in
                    SharedAssessmentSegmentListView(
                        segmentDataModel: segmentDataModel,
                        selectedIndex: selectedIndex,
                        onSegmentSelect: { index in
                            currentIndex = index
                        }
                    )
                }
                
                Divider()
                
                // Example 2: With Custom Content
                SharedAssessmentSegmentControlView(
                    initialIndex: currentIndex,
                    totalCount: 5,
                    onBackTapped: {
                        print("Custom back action")
                    },
                    onForwardTapped: {
                        print("Custom forward action")
                    },
                    onIndexChanged: { index in
                        currentIndex = index
                    }
                ) { selectedIndex in
                    VStack {
                        Text("Question \(selectedIndex + 1)")
                            .font(.title2)
                        Text("Your custom content here")
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
#endif

//
//  SharedAssessmentSegmentListView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 08/10/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import SwiftUI

struct SharedAssessmentSegmentListView<ID: Hashable>: View {
    
    let segmentDataModel: [SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<ID>]
    let selectedIndex: Int
    var onSegmentSelect: ((Int) -> Void)?
    var showSelectionIndicator: Bool = true
    
    @State private var currentIndex: Int
    
    init(
        segmentDataModel: [SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<ID>],
        selectedIndex: Int,
        showSelectionIndicator: Bool = true,
        onSegmentSelect: ((Int) -> Void)? = nil
    ) {
        self.segmentDataModel = segmentDataModel
        self.selectedIndex = selectedIndex
        self.showSelectionIndicator = showSelectionIndicator
        self.onSegmentSelect = onSegmentSelect
        self._currentIndex = State(initialValue: selectedIndex)
    }
    
    var body: some View {
        segmentListView
            .onChange(of: selectedIndex) { newIndex in
                // Sync external changes to internal state
                if newIndex != currentIndex {
                    currentIndex = newIndex
                }
            }
    }
    
    // MARK: - View Components
    
    private var segmentListView: some View {
        ScrollViewReader { proxy in
            scrollContent
                .onChange(of: currentIndex) { newIndex in
                    scrollToSegment(at: newIndex, proxy: proxy)
                }
                .onAppear {
                    scrollToSegment(at: currentIndex, proxy: proxy)
                }
        }
    }
    
    private var scrollContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            segmentStack
        }
        .versionedHorizontalContentMarginsPkg()
    }
    
    private var segmentStack: some View {
        LazyHStack(spacing: 8) {
            ForEach(segmentDataModel.indices, id: \.self) { index in
                segmentItemView(at: index)
            }
        }
    }
    
    private func segmentItemView(at index: Int) -> some View {
        SharedAssessmentSegmentItemView(
            segmentModel: segmentDataModel[index],
            onSegemntSelect: { sequence in
                handleSegmentTap(at: sequence)
            }
        )
        .id(segmentDataModel[index].id)
        .overlay(selectionIndicator(for: index))
        .scaleEffect(selectedIndex == index ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedIndex)
    }
    
    private func selectionIndicator(for index: Int) -> some View {
        Group {
            if showSelectionIndicator && selectedIndex == index {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(ColorUtility.primaryColor, lineWidth: 3)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSegmentTap(at index: Int) {
        guard index >= 0 && index < segmentDataModel.count else { return }
        currentIndex = index
        onSegmentSelect?(index)
    }
    
    private func scrollToSegment(at index: Int, proxy: ScrollViewProxy) {
        guard index >= 0 && index < segmentDataModel.count else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            proxy.scrollTo(segmentDataModel[index].id, anchor: .center)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var currentIndex = 0
        let segmentDataModel = SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel.sampleList
        
        var body: some View {
            VStack(spacing: 20) {
                Text("Selected Segment: \(currentIndex + 1) of \(segmentDataModel.count)")
                    .font(.headline)
                    .padding()
                
                // Segment List with Controls
                SharedAssessmentSegmentControlView(
                    initialIndex: currentIndex,
                    totalCount: segmentDataModel.count,
                    onIndexChanged: { index in
                        currentIndex = index
                        print("Navigated to segment: \(index)")
                    }
                ) { selectedIndex in
                    SharedAssessmentSegmentListView(
                        segmentDataModel: segmentDataModel,
                        selectedIndex: selectedIndex,
                        onSegmentSelect: { index in
                            currentIndex = index
                            print("Segment tapped: \(index)")
                        }
                    )
                }
                
                // Manual controls for testing
                HStack(spacing: 20) {
                    Button("First") {
                        currentIndex = 0
                    }
                    
                    Button("Middle") {
                        currentIndex = segmentDataModel.count / 2
                    }
                    
                    Button("Last") {
                        currentIndex = segmentDataModel.count - 1
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
        }
    }
    
    return PreviewWrapper()
}
#endif

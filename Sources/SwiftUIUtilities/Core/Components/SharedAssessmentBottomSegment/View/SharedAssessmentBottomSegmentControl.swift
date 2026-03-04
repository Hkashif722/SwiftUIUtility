//
//  SharedAssessmentBottomSegmentControl.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 08/10/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import SwiftUI

public struct SharedAssessmentBottomSegmentControl<IDType: Hashable>: View {
        
    let segmentDataModel: [SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<IDType>]
    let selectedIndex: Int
    var showNavigationButtons: Bool = true
    var showSelectionIndicator: Bool = true
    var onSegmentChange: ((Int) -> Void)?
    
    public init(
        segmentDataModel: [SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<IDType>],
        selectedIndex: Int = 0,
        showNavigationButtons: Bool = true,
        showSelectionIndicator: Bool = true,
        onSegmentChange: ((Int) -> Void)? = nil
    ) {
        self.segmentDataModel = segmentDataModel
        self.selectedIndex = selectedIndex
        self.showNavigationButtons = showNavigationButtons
        self.showSelectionIndicator = showSelectionIndicator
        self.onSegmentChange = onSegmentChange
    }
    
    public var body: some View {
        Group {
            if showNavigationButtons {
                navigationControlView
            } else {
                segmentListOnly
            }
        }
    }
    
    private var navigationControlView: some View {
        SharedAssessmentSegmentControlView(
            initialIndex: selectedIndex,
            totalCount: segmentDataModel.count,
            onIndexChanged: { index in
                onSegmentChange?(index)
            }
        ) { currentIndex in
            SharedAssessmentSegmentListView(
                segmentDataModel: segmentDataModel,
                selectedIndex: currentIndex,
                showSelectionIndicator: showSelectionIndicator,
                onSegmentSelect: { index in
                    onSegmentChange?(index)
                }
            )
        }
    }
    
    private var segmentListOnly: some View {
        SharedAssessmentSegmentListView(
            segmentDataModel: segmentDataModel,
            selectedIndex: selectedIndex,
            showSelectionIndicator: showSelectionIndicator,
            onSegmentSelect: { index in
                onSegmentChange?(index)
            }
        )
    }
}





///------------------------------------` Preview`---------------------------------------------------------------------------------
///---------------------------------------------------------------------------------
// MARK: - Preview
#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var currentIndex1 = 0
        @State private var currentIndex2 = 2
        @State private var currentIndex3 = 0
        
        let segmentDataModel = SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel.makeSampleSegments(count: 10)
        
        var body: some View {
            VStack(spacing: 30) {
                // Example 1: With Navigation Buttons (Default)
                VStack(alignment: .leading, spacing: 8) {
                    Text("With Navigation Buttons")
                        .font(.headline)
                    Text("Current: \(currentIndex1 + 1) of \(segmentDataModel.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SharedAssessmentBottomSegmentControl(
                        segmentDataModel: segmentDataModel,
                        selectedIndex: currentIndex1,
                        onSegmentChange: { index in
                            currentIndex1 = index
                            print("Segment changed to: \(index)")
                        }
                    )
                }
                
                Divider()
                
                // Example 2: Without Navigation Buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("List Only (No Buttons)")
                        .font(.headline)
                    Text("Current: \(currentIndex2 + 1) of \(segmentDataModel.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SharedAssessmentBottomSegmentControl(
                        segmentDataModel: segmentDataModel,
                        selectedIndex: currentIndex2,
                        showNavigationButtons: false,
                        onSegmentChange: { index in
                            currentIndex2 = index
                        }
                    )
                }
                
                Divider()
                
                // Example 3: Without Selection Indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("No Selection Indicator")
                        .font(.headline)
                    Text("Current: \(currentIndex3 + 1) of \(segmentDataModel.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SharedAssessmentBottomSegmentControl(
                        segmentDataModel: segmentDataModel,
                        selectedIndex: currentIndex3,
                        showSelectionIndicator: false,
                        onSegmentChange: { index in
                            currentIndex3 = index
                        }
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
#endif

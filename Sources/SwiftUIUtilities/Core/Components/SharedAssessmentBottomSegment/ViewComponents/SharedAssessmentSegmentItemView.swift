//
//  SharedAssessmentSegmentItemView.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 08/10/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import SwiftUI

struct SharedAssessmentSegmentItemView<ID: Hashable>: View {
    
    let segmentModel: SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<ID>
    var onSegemntSelect: ((Int) -> ())?
    
    init(segmentModel: SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel<ID>, onSegemntSelect: ((Int) -> Void)? = nil) {
        self.segmentModel = segmentModel
        self.onSegemntSelect = onSegemntSelect
    }
    
    var body: some View {
        sharedAssessmentSegmentItemView
    }
    
    
    private var sharedAssessmentSegmentItemView: some View {
        segmentItemView
            .onTapGesture {
                onSegemntSelect?(max(segmentModel.sequenceNo - 1, 0))
            }
    }
    
    private var segmentItemView: some View {
        Text(segmentModel.segmentTextRepresentable)
            .font(.callout)
            .padding(8)
            .background(segmentModel.colorState.getBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(segmentModel.colorState.getBorderColor, lineWidth: 2)
            )
    }
}

#if DEBUG
#Preview {
    SharedAssessmentSegmentItemView(
        segmentModel: SharesAssessmentBottomSegmentDataModel.SegmentDataInfoModel.attempted
    )
}
#endif

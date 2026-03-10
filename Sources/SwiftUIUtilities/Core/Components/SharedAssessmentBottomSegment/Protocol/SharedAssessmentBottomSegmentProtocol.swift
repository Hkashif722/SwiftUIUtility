//
//  SharedAssessmentBottomSegmentProtocol.swift
//  Ujjivan
//
//  Created by Kashif Hussain on 08/10/25.
//  Copyright © 2025 EnthrallTech. All rights reserved.
//

import Foundation

public enum SharedAssessmentBottomSegmentProtocol {
    public protocol SegmentInfoProtocol: Identifiable, Comparable, Hashable where ID: Hashable {
        var sequenceNo: Int { get }
        var attempted: Bool { get }
        var notAttempted: Bool { get }
        var visited: Bool { get }
        var colorState: SharesAssessmentBottomSegmentDataModel.SegmentColorState { get }
    }
}

public extension SharedAssessmentBottomSegmentProtocol.SegmentInfoProtocol {
    var segmentTextRepresentable: String {
        "\(sequenceNo)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sequenceNo < rhs.sequenceNo
    }
}

//
//  HeartRateMeter.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/10/26.
//

import SwiftUI

struct HeartRateMeter: View {
    var bpm: Int?
    var maxHeartRate: Int?
    
    private var heartRateFraction: Double {
        guard let bpm = bpm, let maxHR = maxHeartRate, maxHR > 0 else {
            return 0
        }
        return Double(bpm) / Double(maxHR)
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(HeartRateZone.allCases) { zone in
                MeterPill(position:
                            zone == .zone1 ? .leading :
                            zone == .zone5 ? .trailing :
                            .interior,
                          color: zone.color,
                          opacity: heartRateFraction >= zone.range.lowerBound ? 1 : 0.2)
            }
        }
    }
    
    private struct MeterPill: View {
        enum Position {
            case leading
            case interior
            case trailing
        }
        
        var position: Position
        var color: Color
        var opacity: Double
        
        var cornerRadii: RectangleCornerRadii {
            RectangleCornerRadii(
                topLeading: position == .leading ? Constants.m : 0,
                bottomLeading: position == .leading ? Constants.m : 0,
                bottomTrailing: position == .trailing ? Constants.m : 0,
                topTrailing: position == .trailing ? Constants.m : 0)
        }
        
        var body: some View {
            UnevenRoundedRectangle(cornerRadii: cornerRadii)
                .frame(height: 6)
                .foregroundStyle(color.opacity(opacity))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Zone 1 (50-60% of 180 = 90-108 bpm)
        HeartRateMeter(bpm: 100, maxHeartRate: 180)
        
        // Zone 2 (60-70% of 180 = 108-126 bpm)
        HeartRateMeter(bpm: 117, maxHeartRate: 180)
        
        // Zone 3 (70-80% of 180 = 126-144 bpm)
        HeartRateMeter(bpm: 135, maxHeartRate: 180)
        
        // Zone 4 (80-90% of 180 = 144-162 bpm)
        HeartRateMeter(bpm: 153, maxHeartRate: 180)
        
        // Zone 5 (90-100% of 180 = 162-180 bpm)
        HeartRateMeter(bpm: 170, maxHeartRate: 180)
        
        // No max HR set
        HeartRateMeter(bpm: 120, maxHeartRate: nil)
    }
    .padding()
}

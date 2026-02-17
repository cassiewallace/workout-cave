//
//  MetricCard.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct MetricCard: View {
    let type: Metric
    let value: String
    var heartRateBpm: Int?
    var maxHeartRate: Int?
    
    @ScaledMetric(relativeTo: .body) var fontSize: CGFloat = 14
    @ScaledMetric(relativeTo: .body) var maxHeight: CGFloat = 120
    @ScaledMetric(relativeTo: .body) var maxWidth: CGFloat = .infinity
    @ScaledMetric(relativeTo: .body) var horizontalPadding: CGFloat = Constants.s
    @ScaledMetric(relativeTo: .body) var verticalPadding: CGFloat = Constants.xl
    
    // Heart rate cards need tighter spacing between elements to fit the meter
    private var contentSpacing: CGFloat {
        type == .heartRate ? Constants.xxs : Constants.xs
    }

    var body: some View {
        VStack(spacing: contentSpacing) {
            Text(type.rawValue.capitalized)
                .font(.system(size: fontSize, weight: .semibold))
                .lineLimit(1)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: fontSize * 2.5, weight: .bold))
            
            if type == .heartRate {
                HeartRateMeter(bpm: heartRateBpm, maxHeartRate: maxHeartRate)
            }
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .center)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .styledCard()
    }
}

#Preview {
    VStack {
        HStack {
            MetricCard(type: .cadence, value: String(90))
            MetricCard(type: .power, value: String(180))
            MetricCard(type: .heartRate, value: String(126), heartRateBpm: 126, maxHeartRate: 180)
        }
        MetricCard(type: .heartRate, value: String(162), heartRateBpm: 162, maxHeartRate: 180)
        
        // Without max HR set
        MetricCard(type: .heartRate, value: String(120), heartRateBpm: 120, maxHeartRate: nil)
    }
    .padding()
}

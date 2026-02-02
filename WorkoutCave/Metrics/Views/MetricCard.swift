//
//  MetricCard.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct MetricCard: View {
    let name: String
    let value: String
    
    @ScaledMetric(relativeTo: .body) var fontSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) var maxHeight: CGFloat = 120
    @ScaledMetric(relativeTo: .body) var maxWidth: CGFloat = .infinity
    @ScaledMetric(relativeTo: .body) var horizontalPadding: CGFloat = Constants.s
    @ScaledMetric(relativeTo: .body) var verticalPadding: CGFloat = Constants.xl

    var body: some View {
        VStack(spacing: Constants.xs) {
            Text(name)
                .font(.system(size: fontSize, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(value)
                .font(.system(size: fontSize * 2, weight: .bold))
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: maxWidth, maxHeight: maxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .styledCard()
    }
}

#Preview {
    HStack {
        MetricCard(name: Copy.metrics.cadence, value: String(90))
        MetricCard(name: Copy.metrics.power, value: String(180))
        MetricCard(name: Copy.metrics.heartRate, value: String(111))
    }
    .padding()
}

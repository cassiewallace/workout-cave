//
//  MetricCard.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct MetricCard: View {
    var name: String
    var value: String
    
    @ScaledMetric(relativeTo: .body) var fontSize: CGFloat = 18
    @ScaledMetric(relativeTo: .body) var maxHeight: CGFloat = 120
    @ScaledMetric(relativeTo: .body) var maxWidth: CGFloat = .infinity

    var body: some View {
        if #available(iOS 26.0, *) {
            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: fontSize, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(value)
                    .font(.system(size: fontSize * 2, weight: .bold))
            }
            .padding()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .fixedSize(horizontal: false, vertical: true)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 8))
        } else {
            VStack(spacing: 4) {
                Text(name)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(value)
                    .font(Font.largeTitle.bold())
            }
            .padding()
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .fixedSize(horizontal: false, vertical: true)
            .background(.quaternary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 1)
            )
        }
    }
}

#Preview {
    HStack {
        MetricCard(name: "Cadence", value: "90")
        MetricCard(name: "Watts", value: "180")
        MetricCard(name: "Heart Rate", value: "111")
    }
    .padding()
}

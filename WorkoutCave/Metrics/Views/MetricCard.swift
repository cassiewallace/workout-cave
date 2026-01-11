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
    
    @ScaledMetric(relativeTo: .body) private var tileMinHeight: CGFloat = 120

    var body: some View {
        VStack(spacing: 4) {
            Text(name)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(Font.largeTitle.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: tileMinHeight)
        .fixedSize(horizontal: false, vertical: true)
        .background(.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary, lineWidth: 1)
        )
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

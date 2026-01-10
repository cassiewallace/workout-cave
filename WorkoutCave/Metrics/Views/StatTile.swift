//
//  StatTile.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct MetricTile: View {
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary, lineWidth: 1)
        )
    }
}

#Preview {
    HStack {
        MetricTile(name: "Cadence", value: "90")
        MetricTile(name: "Watts", value: "180")
        MetricTile(name: "Heart Rate", value: "111")
    }
    .padding()
}

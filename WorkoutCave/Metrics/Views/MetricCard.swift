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
    
    private let cornerRadius: CGFloat = Constants.s

    var body: some View {
        styledCard(baseCard)
    }
    
    private var baseCard: some View {
        VStack(spacing: Constants.xxs) {
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
        .accessibilityElement(children: .combine)
    }
    
    @ViewBuilder
    private func styledCard<Content: View>(_ content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.primary, lineWidth: 1)
                )
        }
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

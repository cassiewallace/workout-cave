//
//  CardStyle.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/21/26.
//

import SwiftUI

private struct StyledCard: ViewModifier {
    private let cornerRadius: CGFloat = Constants.s
    
    func body(content: Content) -> some View {
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

extension View {
    func styledCard() -> some View {
        modifier(StyledCard())
    }
}

//
//  CardStyle.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/21/26.
//

import SwiftUI

private struct StyledCard: ViewModifier {
    private let cornerRadius: CGFloat = Constants.m
    private let backgroundColor: Color = .white.opacity(0.90)
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: cornerRadius))
                .glassEffect(
                    .regular.tint(.white).interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(.white, lineWidth: 0.5)
                )
        }
    }
}

extension View {
    func styledCard() -> some View {
        modifier(StyledCard())
    }
}

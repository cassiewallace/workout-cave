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
                .background(.white, in: RoundedRectangle(cornerRadius: cornerRadius))
                .glassEffect(
                    .regular.tint(.white).interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .background(.white)
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

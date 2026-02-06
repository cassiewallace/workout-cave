//
//  Onboarding.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import SwiftUI

struct Onboarding: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Image("intro-bike")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [
                        Color(.systemBackground).opacity(0.10),
                        Color(.systemBackground).opacity(0.70),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: Constants.l) {
                    Spacer()

                    Text(Copy.onboarding.description)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, Constants.xl)
                        .padding(.vertical, Constants.m)

                    ctaButton
                }
                .padding(.horizontal, Constants.xxl)
                .padding(.bottom, Constants.xxl)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(.primary)
                    .accessibilityLabel(Copy.accessibility.close)
                }
            }
        }
    }

    @ViewBuilder
    private var ctaButton: some View {
        let label = Text(Copy.onboarding.cta)
            .padding(.horizontal, Constants.l)
            .padding(.vertical, Constants.s)
        let button = Button(action: onDismiss) { label }

        styleCTAButton(button)
    }

    @ViewBuilder
    private func styleCTAButton<Label: View>(_ button: Button<Label>) -> some View {
        if #available(iOS 26.0, *) {
            button
                .buttonStyle(.glass)
                .buttonBorderShape(.roundedRectangle(radius: 16))
        } else {
            button
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 16))
                .tint(.primary)
                .foregroundStyle(.background)
        }
    }
}

#Preview {
    Onboarding(onDismiss: {})
}

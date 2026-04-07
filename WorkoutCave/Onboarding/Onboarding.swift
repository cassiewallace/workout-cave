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
            VStack(spacing: Constants.l) {
                Spacer()

                WorkoutPreviewCard()
                    .opacity(0.85)
                    .padding()
                    .accessibilityHidden(true)

                VStack(spacing: Constants.s) {
                    Text(Copy.onboarding.headline)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    Text(Copy.onboarding.description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.85))
                }

                ctaButton
            }
            .padding(.horizontal, Constants.xxl)
            .padding(.bottom, Constants.xxl)
            .frame(maxWidth: 480)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(.white)
                    .accessibilityLabel(Copy.accessibility.close)
                }
            }
        }
        .presentationBackground {
            Image("intro-bike")
                .resizable()
                .scaledToFill()
                .accessibilityLabel(Copy.accessibility.introImage)
                .overlay {
                    LinearGradient(
                        colors: [
                            Color(.black).opacity(0.10),
                            Color(.black).opacity(0.70),
                            Color(.black).opacity(0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
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
                .tint(.white)
                .foregroundStyle(.black)
        }
    }
}

private struct WorkoutPreviewCard: View {
    private let metrics: [(label: String, value: String)] = [
        (Copy.metrics.targetZone, Copy.onboarding.preview.targetZoneValue),
        (Copy.metrics.currentZone, Copy.onboarding.preview.currentZoneValue),
        (Copy.metrics.power, Copy.onboarding.preview.powerValue),
        (Copy.metrics.cadence, Copy.onboarding.preview.cadenceValue),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.m) {
            HStack {
                Text(Copy.onboarding.preview.intervalName)
                    .font(.headline)
                    .foregroundStyle(Color("CardTitle"))

                Spacer()

                Image("bluetooth-connected")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.l, height: Constants.l)
                    .foregroundStyle(Color("NeonGreen"))
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Constants.s
            ) {
                ForEach(metrics, id: \.label) { metric in
                    PreviewMetricCell(label: metric.label, value: metric.value)
                }
            }

            Text(Copy.onboarding.preview.timer)
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color("CardTitle"))
                .frame(maxWidth: .infinity, alignment: .center)

            ProgressView(value: 0.38)
                .tint(Color("NeonGreen"))
        }
        .padding(Constants.l)
        .styledCard()
    }
}

private struct PreviewMetricCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.xxs) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("CardSubtitle"))
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color("CardTitle"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.s)
        .background(Color("CardBackground").opacity(0.5), in: RoundedRectangle(cornerRadius: Constants.s))
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            Onboarding(onDismiss: {})
        }
}

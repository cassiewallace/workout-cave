//
//  BluetoothPromptCard.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 4/7/26.
//

import SwiftUI

struct BluetoothPromptCard: View {
    let onConnect: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.m) {
            HStack(spacing: Constants.m) {
                Image("bluetooth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.xl, height: Constants.xl)
                    .foregroundStyle(Color("NeonGreen"))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Constants.xxs) {
                    Text(Copy.bluetoothPrompt.title)
                        .font(.headline)
                        .foregroundStyle(Color("CardTitle"))

                    Text(Copy.bluetoothPrompt.body)
                        .font(.subheadline)
                        .foregroundStyle(Color("CardSubtitle"))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: Constants.m) {
                Button(Copy.bluetoothPrompt.connectCTA, action: onConnect)
                    .buttonStyle(.borderedProminent)

                Button(Copy.bluetoothPrompt.skipCTA, action: onSkip)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Constants.l)
        .styledCard()
    }
}

#Preview {
    BluetoothPromptCard(onConnect: {}, onSkip: {})
        .padding()
}

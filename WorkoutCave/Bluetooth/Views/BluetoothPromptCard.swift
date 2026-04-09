//
//  BluetoothPromptCard.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 4/7/26.
//

import SwiftUI

struct BluetoothPromptCard: View {
    let onDismiss: () -> Void

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

            Button(Copy.bluetoothPrompt.dismissCTA, action: onDismiss)
                .buttonStyle(.bordered)
        }
        .padding(Constants.l)
        .styledCard()
    }
}

#Preview {
    BluetoothPromptCard(onDismiss: {})
        .padding()
}

//
//  BluetoothDialog.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/22/26.
//

import SwiftUI

struct BluetoothDialog: View {
    @ObservedObject var bluetooth: BluetoothManager
    
    private let cornerRadius: CGFloat = Constants.l
    private let spacing: CGFloat = Constants.l
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if bluetooth.state == .unauthorized {
                statusText(Copy.bluetooth.dialogUnauthorized)
            } else if bluetooth.state == .poweredOff {
                statusText(Copy.bluetooth.dialogPoweredOff)
            } else if bluetooth.discoveredPeripherals.isEmpty {
                statusText(Copy.bluetooth.dialogSearching)
            } else {
                deviceList
            }
        }
    }
    
    private var deviceList: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            ForEach(bluetooth.discoveredPeripherals) { device in
                Button {
                    bluetooth.connect(to: device.id)
                } label: {
                    HStack {
                        Image("bluetooth")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(device.name)
                        Spacer()
                    }
                }
                .tint(.primary)
                .accessibilityHint(Copy.accessibility.connectHint)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func statusText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .font(.body)
    }
}

#Preview("Empty") {
    let bluetooth = BluetoothManager()
    return List {
        Section("Connect") {
            BluetoothDialog(bluetooth: bluetooth)
        }
    }
}

#Preview("Single Device") {
    let bluetooth = BluetoothManager()
    let peripheral = DiscoveredPeripheral(id: UUID(), name: "Schwinn IC4", rssi: 1)
    bluetooth.discoveredPeripherals = [peripheral]
    return List {
        Section("Connect") {
            BluetoothDialog(bluetooth: bluetooth)
        }
    }
}

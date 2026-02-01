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
        Section("Connect to devices") {
            VStack(spacing: spacing) {
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
    }
    
    private var deviceList: some View {
        VStack(spacing: Constants.s) {
            ForEach(bluetooth.discoveredPeripherals) { device in
                Button {
                    bluetooth.connect(to: device.id)
                } label: {
                        Image("bluetooth")
                        Text(device.name)
                    }
                }
                .tint(.primary)
            }
        }

    private func statusText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .font(.body)
            .multilineTextAlignment(.center)
    }
}

#Preview {
    var bluetoothEmpty: BluetoothManager {
        let bluetooth = BluetoothManager()
        return bluetooth
    }
    
    var bluetoothOne: BluetoothManager {
        let bluetooth = BluetoothManager()
        let peripheral = DiscoveredPeripheral(id: UUID(), name: "Schwinn IC4", rssi: 1)
        bluetooth.discoveredPeripherals = [peripheral]
        return bluetooth
    }
    
    VStack(spacing: 36) {
        Menu {
            BluetoothDialog(bluetooth: bluetoothEmpty)
        } label: {
            Text("Empty")
        }
        Menu {
            BluetoothDialog(bluetooth: bluetoothOne)
        } label: {
            Text("Single Device")
        }
    }
}

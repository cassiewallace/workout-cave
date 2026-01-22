//
//  BluetoothDialog.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/22/26.
//

import SwiftUI

struct BluetoothDialog: View {
    @ObservedObject var bluetooth: BluetoothManager
    
    private let cornerRadius: CGFloat = Constants.m
    private let spacing: CGFloat = Constants.l
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(Copy.bluetooth.dialogTitle)
                .font(.title2)
                .bold()
                .padding(.bottom, Constants.s)
            Divider()
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
        .padding(Constants.xxl)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.white, lineWidth: 0.5)
        )
    }
    
    private var deviceList: some View {
        VStack(spacing: Constants.m) {
            ForEach(bluetooth.discoveredPeripherals) { device in
                Button {
                    bluetooth.connect(to: device.id)
                } label: {
                    HStack(spacing: Constants.m) {
                        Image("bluetooth")
                            .resizable()
                            .frame(width: 20, height: 20)
                        VStack(alignment: .leading, spacing: Constants.xxs) {
                            Text(device.name)
                                .font(.headline)
                            Text(rssiLabel(for: device.rssi))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer(minLength: Constants.s)
                    }
                }
                .tint(.primary)
            }
        }
    }

    private func statusText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .font(.body)
    }

    private func rssiLabel(for rssi: Int) -> String {
        "\(rssi) dBm"
    }
}

#Preview {
    var bluetooth: BluetoothManager {
        let bluetooth = BluetoothManager()
        return bluetooth
    }
    
    BluetoothDialog(bluetooth: bluetooth)
        .padding()
}

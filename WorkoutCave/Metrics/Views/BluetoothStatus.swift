//
//  BluetoothStatus.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftUI

private struct BluetoothStatusIndicator: View {
    @State var bluetooth: BluetoothManager
    
    var body: some View {
        statusIcon
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(statusIconTint)
            .accessibilityHint(statusText)
            .onTapGesture {
                bluetooth.activateAndConnect()
            }
    }
    
    private var statusIconTint: Color {
        switch bluetooth.state {
        case .connecting, .connected:
            return .blue
        default:
            return .gray
        }
    }

    private var statusIcon: Image {
        switch bluetooth.state {
        case .idle:
            return Image(Constants.AssetImage.bluetooth)
        case .scanning:
            return Image(Constants.AssetImage.bluetooth)
        case .unauthorized:
            return Image(Constants.AssetImage.bluetoothX)
        case .poweredOff:
            return Image(Constants.AssetImage.bluetoothSlash)
        case .connecting:
            return Image(Constants.AssetImage.bluetooth)
        case .connected:
            return Image(Constants.AssetImage.bluetoothConnected)
        }
    }

    private var statusText: String {
        switch bluetooth.state {
        case .idle: return Constants.Bluetooth.StatusText.idle
        case .scanning: return Constants.Bluetooth.StatusText.scanning
        case .unauthorized: return Constants.Bluetooth.StatusText.unauthorized
        case .poweredOff: return Constants.Bluetooth.StatusText.poweredOff
        case .connecting: return Constants.Bluetooth.StatusText.connecting
        case .connected: return Constants.Bluetooth.StatusText.connected
        }
    }

}

private struct BluetoothStatus: ViewModifier {
    var bluetooth: BluetoothManager
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                BluetoothStatusIndicator(bluetooth: bluetooth)
            }
    }
}

extension View {
    func bluetoothStatus(using bluetooth: BluetoothManager) -> some View {
        modifier(BluetoothStatus(bluetooth: bluetooth))
    }
}

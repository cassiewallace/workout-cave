//
//  BluetoothStatus.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftUI

private struct BluetoothStatusIndicator: View {
    @ObservedObject var bluetooth: BluetoothManager
    
    private let iconSize: CGFloat = Constants.xl
    
    var body: some View {
        statusIcon
            .resizable()
            .frame(width: iconSize, height: iconSize)
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
            return Image("bluetooth")
        case .scanning:
            return Image("bluetooth")
        case .unauthorized:
            return Image("bluetooth-x")
        case .poweredOff:
            return Image("bluetooth-slash")
        case .connecting:
            return Image("bluetooth")
        case .connected:
            return Image("bluetooth-connected")
        }
    }

    private var statusText: String {
        switch bluetooth.state {
        case .idle: return Copy.bluetooth.statusText.idle
        case .scanning: return Copy.bluetooth.statusText.scanning
        case .unauthorized: return Copy.bluetooth.statusText.unauthorized
        case .poweredOff: return Copy.bluetooth.statusText.poweredOff
        case .connecting: return Copy.bluetooth.statusText.connecting
        case .connected: return Copy.bluetooth.statusText.connected
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

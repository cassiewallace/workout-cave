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
        case .idle: return "Idle"
        case .scanning: return "Searching for bike"
        case .unauthorized: return "Bluetooth permission denied"
        case .poweredOff: return "Bluetooth is off"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
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

//
//  Stats.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftData
import SwiftUI

struct Metrics: View {
    @StateObject var bluetooth = BluetoothManager()
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(name: "Power Zone",
                           value: powerZoneLabel(watts: bluetooth.metrics.powerWatts))
                MetricCard(name: "Power", value: bluetooth.metrics.powerWatts.map(String.init) ?? "—")
            }

            HStack(spacing: 12) {
                MetricCard(name: "Cadence", value: bluetooth.metrics.cadenceRpm.map { "\(Int($0.rounded()))" } ?? "—")
                MetricCard(name: "Speed", value: bluetooth.metrics.speedKph.map { String(format: "%.1f", $0) } ?? "—")
            }

            HStack(spacing: 12) {
                MetricCard(name: "Heart Rate", value: bluetooth.metrics.heartRateBpm.map(String.init) ?? "—")
            }
        }
        .padding()
        .navigationTitle("Just Ride")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            bluetoothStatusIndicator
        }
    }

    @ViewBuilder
    private var bluetoothStatusIndicator: some View {
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
        case .scanning: return "Searching for bike…"
        case .unauthorized: return "Bluetooth permission denied"
        case .poweredOff: return "Bluetooth is off"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
    
    private func powerZoneLabel(watts: Int?) -> String {
        guard let watts, watts > 0, let zone = userSettings?.powerZone(for: watts) else { return "—" }
        return zone.name
    }
}

#Preview {
    NavigationStack {
        Metrics()
    }
}

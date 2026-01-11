//
//  Stats.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct Metrics: View {
    @StateObject private var bluetooth = BluetoothManager()
    @Environment(\.modelContext) private var modelContext
    @State private var settings: UserSettings?

    var body: some View {
        VStack(spacing: 12) {
            statusRow
            
            HStack(spacing: 12) {
                MetricCard(name: "Power", value: bluetooth.metrics.powerWatts.map(String.init) ?? "—")
                MetricCard(name: "Power Zone", value: settings?.powerZone(for: bluetooth.metrics.powerWatts)?.name ?? "—")
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
    }

    @ViewBuilder
    private var statusRow: some View {
        if let statusText {
            Text(statusText)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var statusText: String? {
        switch bluetooth.state {
        case .idle: return "Idle"
        case .scanning: return "Searching for bike…"
        case .unauthorized: return "Bluetooth permission denied"
        case .poweredOff: return "Bluetooth is off"
        case .connecting: return "Connecting"
        case .connected: return nil
        }
    }
}

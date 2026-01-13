//
//  Stats.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftData
import SwiftUI

struct Metrics: View {
    @StateObject private var bluetooth = BluetoothManager()
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    var body: some View {
        VStack(spacing: 12) {
            statusRow
            
            HStack(spacing: 12) {
                MetricCard(name: "Power Zone", value: userSettings?.powerZone(for: bluetooth.metrics.powerWatts)?.name ?? "—")
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

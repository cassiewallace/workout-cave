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
                           value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts))
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
        .bluetoothStatus(using: bluetooth)
    }
}

#Preview {
    NavigationStack {
        Metrics()
    }
}

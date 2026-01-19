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
                MetricCard(name: Constants.Metrics.powerZone,
                           value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts))
                MetricCard(name: Constants.Metrics.power, value: bluetooth.metrics.powerWatts.map(String.init) ?? Constants.Placeholder.missingValue)
            }

            HStack(spacing: 12) {
                MetricCard(name: Constants.Metrics.cadence, value: bluetooth.metrics.cadenceRpm.map { String(Int($0.rounded())) } ?? Constants.Placeholder.missingValue)
                MetricCard(name: Constants.Metrics.speed, value: bluetooth.metrics.speedKph.map { String(format: Constants.Format.oneDecimal, $0) } ?? Constants.Placeholder.missingValue)
            }

            HStack(spacing: 12) {
                MetricCard(name: Constants.Metrics.heartRate, value: bluetooth.metrics.heartRateBpm.map(String.init) ?? Constants.Placeholder.missingValue)
            }
        }
        .padding()
        .navigationTitle(Constants.NavigationTitle.justRide)
        .navigationBarTitleDisplayMode(.inline)
        .bluetoothStatus(using: bluetooth)
    }
}

#Preview {
    NavigationStack {
        Metrics()
    }
}

//
//  Stats.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftData
import SwiftUI

struct Metrics: View {
    @EnvironmentObject private var bluetooth: BluetoothManager
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    var body: some View {
        VStack(spacing: Constants.m) {
            HStack(spacing: Constants.m) {
                MetricCard(name: Copy.metrics.powerZone,
                           value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts))
                MetricCard(name: Copy.metrics.power, value: bluetooth.metrics.powerWatts.map(String.init) ?? Copy.placeholder.missingValue)
            }

            HStack(spacing: Constants.m) {
                MetricCard(name: Copy.metrics.cadence, value: bluetooth.metrics.cadenceRpm.map { String(Int($0.rounded())) } ?? Copy.placeholder.missingValue)
                MetricCard(name: Copy.metrics.speed, value: bluetooth.metrics.speedKph.map { String(format: Copy.format.oneDecimal, $0) } ?? Copy.placeholder.missingValue)
            }

            HStack(spacing: Constants.m) {
                MetricCard(name: Copy.metrics.heartRate, value: bluetooth.metrics.heartRateBpm.map(String.init) ?? Copy.placeholder.missingValue)
            }
        }
        .padding()
        .navigationTitle(Copy.navigationTitle.justRide)
        .navigationBarTitleDisplayMode(.inline)
        .bluetoothStatus(using: bluetooth)
    }
}

#Preview {
    MetricsPreviewHost()
}

private struct MetricsPreviewHost: View {
    @StateObject private var bluetooth = BluetoothManager()
    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()
    
    var body: some View {
        NavigationStack {
            Metrics()
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
    }
}

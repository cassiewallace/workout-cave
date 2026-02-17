//
//  LiveMetricsGrid.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftData
import SwiftUI

struct LiveMetricsGrid: View {
    let bluetooth: BluetoothManager
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }
    
    var targetZoneLabel: String?
    var zoneTitle: String
    var metrics: [Metric]
    var averagePowerLabel: String?
    var columnsPerRow: Int
    var fontSize: CGFloat
    var maxHeight: CGFloat
    var maxWidth: CGFloat
    
    init(
        bluetooth: BluetoothManager,
        targetZoneLabel: String? = nil,
        zoneTitle: String = Copy.metrics.powerZone,
        metrics: [Metric] = [.zone, .power, .cadence, .speed, .heartRate],
        averagePowerLabel: String? = nil,
        columnsPerRow: Int = 2,
        fontSize: CGFloat = 18,
        maxHeight: CGFloat = 120,
        maxWidth: CGFloat = .infinity
    ) {
        self.bluetooth = bluetooth
        self.targetZoneLabel = targetZoneLabel
        self.zoneTitle = zoneTitle
        self.metrics = metrics
        self.averagePowerLabel = averagePowerLabel
        self.columnsPerRow = max(1, columnsPerRow)
        self.fontSize = fontSize
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
    }
    
    var body: some View {
        VStack(spacing: Constants.m) {
            let rows = metricRows(maxRows: 3)

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                if columnsPerRow == 1 {
                    VStack(spacing: Constants.m) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, metric in
                            metricCard(metric, targetZoneLabel: targetZoneLabel)
                        }
                    }
                } else {
                    HStack(spacing: Constants.m) {
                        ForEach(Array(row.enumerated()), id: \.offset) { _, metric in
                            metricCard(metric, targetZoneLabel: targetZoneLabel)
                        }
                    }
                }
            }
        }
        .frame(alignment: .top)
    }

    private var speedUnit: SpeedUnit {
        userSettings?.speedUnit ?? .mph
    }

    private var speedLabel: String {
        "\(Copy.metrics.speed) (\(speedUnit.rawValue))"
    }
    
    private func metricRows(maxRows: Int) -> [[Metric]] {
        var rows: [[Metric]] = []
        
        // Row 1: Power-related metrics (targetZone, zone, power, averagePower)
        var powerRow: [Metric] = []
        if metrics.contains(.targetZone), targetZoneLabel != nil {
            powerRow.append(.targetZone)
        }
        if metrics.contains(.zone) {
            powerRow.append(.zone)
        }
        if metrics.contains(.power) {
            powerRow.append(.power)
        }
        if metrics.contains(.averagePower) {
            powerRow.append(.averagePower)
        }
        if !powerRow.isEmpty && rows.count < maxRows {
            rows.append(powerRow)
        }
        
        // Row 2: Speed and Cadence
        var speedCadenceRow: [Metric] = []
        if metrics.contains(.speed) {
            speedCadenceRow.append(.speed)
        }
        if metrics.contains(.cadence) {
            speedCadenceRow.append(.cadence)
        }
        if !speedCadenceRow.isEmpty && rows.count < maxRows {
            rows.append(speedCadenceRow)
        }
        
        // Row 3: Heart Rate (gets its own row)
        if metrics.contains(.heartRate) && rows.count < maxRows {
            rows.append([.heartRate])
        }
        
        return rows
    }
    
    @ViewBuilder
    private func metricCard(_ metric: Metric, targetZoneLabel: String?) -> some View {
        switch metric {
        case .averagePower:
            MetricCard(
                type: .averagePower,
                value: averagePowerLabel ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .targetZone:
            MetricCard(
                type: .targetZone,
                value: targetZoneLabel ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .zone:
            MetricCard(
                type: .zone,
                value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts),
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .power:
            MetricCard(
                type: .power,
                value: bluetooth.metrics.powerWatts.map(String.init) ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .cadence:
            MetricCard(
                type: .cadence,
                value: bluetooth.metrics.cadenceRpm.map { String(Int($0.rounded())) } ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .speed:
            MetricCard(
                type: .speed,
                value: speedValueLabel() ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .heartRate:
            MetricCard(
                type: .heartRate,
                value: bluetooth.metrics.heartRateBpm.map(String.init) ?? Copy.placeholder.missingValue,
                heartRateBpm: bluetooth.metrics.heartRateBpm,
                maxHeartRate: userSettings?.maxHR,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        }
    }

    private func speedValueLabel() -> String? {
        guard let kph = bluetooth.metrics.speedKph else { return nil }
        let value: Double
        switch speedUnit {
        case .mph:
            value = kph * 0.621_371
        case .kph:
            value = kph
        }
        return String(format: Copy.format.oneDecimal, value)
    }
}

#Preview {
    LiveMetricsGridPreviewHost()
}

private struct LiveMetricsGridPreviewHost: View {
    private var bluetooth: BluetoothManager {
        let manager = BluetoothManager()
        manager.metrics.heartRateBpm = 100
        return manager
    }
    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250, maxHR: 180))
        try? context.save()
        return c
    }()
    
    var body: some View {
        TabView {
            LiveMetricsGrid(
                bluetooth: bluetooth,
                targetZoneLabel: "Z2–Z3",
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.targetZone, .zone, .power, .cadence, .speed, .heartRate]
            )
            .padding()
            
            LiveMetricsGrid(
                bluetooth: bluetooth,
                targetZoneLabel: "Z1",
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.zone, .heartRate],
                columnsPerRow: 1,
                fontSize: 12,
                maxHeight: 80,
                maxWidth: 120
            )
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}


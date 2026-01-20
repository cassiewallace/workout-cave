//
//  LiveMetricsGrid.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftData
import SwiftUI

struct LiveMetricsGrid: View {
    enum Metric: Hashable {
        case targetZone
        case zone
        case power
        case cadence
        case speed
        case heartRate
    }
    
    @EnvironmentObject private var bluetooth: BluetoothManager
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }
    
    var targetZoneLabel: String?
    var zoneTitle: String
    var metrics: [Metric]
    var columnsPerRow: Int
    var fontSize: CGFloat
    var maxHeight: CGFloat
    var maxWidth: CGFloat
    
    init(
        targetZoneLabel: String? = nil,
        zoneTitle: String = Copy.metrics.powerZone,
        metrics: [Metric] = [.zone, .power, .cadence, .speed, .heartRate],
        columnsPerRow: Int = 2,
        fontSize: CGFloat = 18,
        maxHeight: CGFloat = 120,
        maxWidth: CGFloat = .infinity
    ) {
        self.targetZoneLabel = targetZoneLabel
        self.zoneTitle = zoneTitle
        self.metrics = metrics
        self.columnsPerRow = max(1, columnsPerRow)
        self.fontSize = fontSize
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
    }
    
    var body: some View {
        VStack(spacing: Constants.m) {
            let rows = metricRows(maxRows: 3)

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: Constants.m) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, metric in
                        metricCard(metric, targetZoneLabel: targetZoneLabel)
                    }
                }
            }
        }
    }
    
    private func metricRows(maxRows: Int) -> [[Metric]] {
        // Build a dedicated "zone row" so Target Zone + Current Zone
        // always appear together when available.
        var zoneRow: [Metric] = []
        if metrics.contains(.targetZone), targetZoneLabel != nil {
            zoneRow.append(.targetZone)
        }
        if metrics.contains(.zone) {
            zoneRow.append(.zone)
        }

        let remaining = metrics.filter { metric in
            switch metric {
            case .targetZone:
                return !(metrics.contains(.targetZone) && targetZoneLabel != nil)
            case .zone:
                return false
            default:
                return true
            }
        }
        
        var rows: [[Metric]] = []
        if !zoneRow.isEmpty {
            rows.append(zoneRow)
        }

        let remainingRowCapacity = max(0, maxRows - rows.count)
        guard remainingRowCapacity > 0 else { return rows }

        var i = 0
        while i < remaining.count, rows.count < maxRows {
            let end = min(i + columnsPerRow, remaining.count)
            rows.append(Array(remaining[i..<end]))
            i = end
        }
        return rows
    }
    
    @ViewBuilder
    private func metricCard(_ metric: Metric, targetZoneLabel: String?) -> some View {
        switch metric {
        case .targetZone:
            MetricCard(
                name: Copy.metrics.targetZone,
                value: targetZoneLabel ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .zone:
            MetricCard(
                name: zoneTitle,
                value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts),
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .power:
            MetricCard(
                name: Copy.metrics.power,
                value: bluetooth.metrics.powerWatts.map(String.init) ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .cadence:
            MetricCard(
                name: Copy.metrics.cadence,
                value: bluetooth.metrics.cadenceRpm.map { String(Int($0.rounded())) } ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .speed:
            MetricCard(
                name: Copy.metrics.speed,
                value: bluetooth.metrics.speedKph.map { String(format: Copy.format.oneDecimal, $0) } ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        case .heartRate:
            MetricCard(
                name: Copy.metrics.heartRate,
                value: bluetooth.metrics.heartRateBpm.map(String.init) ?? Copy.placeholder.missingValue,
                fontSize: fontSize,
                maxHeight: maxHeight,
                maxWidth: maxWidth
            )
        }
    }
}

#Preview {
    LiveMetricsGridPreviewHost()
}

private struct LiveMetricsGridPreviewHost: View {
    @StateObject private var bluetooth = BluetoothManager()
    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()
    
    var body: some View {
        TabView {
            LiveMetricsGrid(
                targetZoneLabel: "Z2–Z3",
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.targetZone, .zone, .power, .cadence, .speed, .heartRate]
            )
            .padding()
            
            LiveMetricsGrid(
                targetZoneLabel: "Z1",
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.zone, .heartRate],
                columnsPerRow: 1,
                fontSize: 12,
                maxHeight: 64,
                maxWidth: 96
            )
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}


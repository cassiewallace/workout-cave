//
//  ZoneSettings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import SwiftUI

/// A single row in the zones grid: zone number (e.g. "Z1"), name, and target range string.
struct ZoneRowDisplay {
    let zoneNumber: String
    let zoneName: String
    let targetRange: String
}

/// Reusable settings screen with an input field and a zones grid (used for Power Zones and Heart Rate Zones).
struct ZoneSettings: View {
    let navigationTitle: String
    let inputLabel: String
    let inputPlaceholder: String
    @Binding var inputText: String
    /// Current saved value, if any; used to disable Save when the field is unchanged.
    let savedValue: Int?
    let onSave: () -> Void
    let zonesSectionTitle: String
    let emptyMessage: String
    let zoneRows: [ZoneRowDisplay]

    /// Show the zones grid when the field contains a positive number.
    private var hasValidValue: Bool {
        (Int(inputText) ?? 0) > 0
    }

    /// Save is disabled when the field is empty or when the value is unchanged from savedValue.
    private var saveDisabled: Bool {
        inputText.isEmpty || (savedValue != nil && Int(inputText) == savedValue)
    }

    var body: some View {
        List {
            inputSection
            zonesSection
        }
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.insetGrouped)
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(inputLabel)
                .font(.title3)
                .bold()

            HStack {
                TextField(inputPlaceholder, text: $inputText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Button(Copy.settings.save, action: onSave)
                    .buttonStyle(.borderedProminent)
                    .disabled(saveDisabled)
            }
        }
    }

    private var zonesSection: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(zonesSectionTitle)
                .font(.title2)
                .bold()

            if hasValidValue, !zoneRows.isEmpty {
                Grid(
                    alignment: .leading,
                    horizontalSpacing: Constants.m,
                    verticalSpacing: Constants.xs + Constants.xxs
                ) {
                    GridRow {
                        Text(Copy.settings.gridZone)
                        Text(Copy.settings.gridName)
                        Text(Copy.settings.gridTarget)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Divider().gridCellColumns(3)

                    ForEach(Array(zoneRows.enumerated()), id: \.offset) { _, row in
                        GridRow {
                            Text(row.zoneNumber)
                                .fontWeight(.semibold)
                                .frame(width: 44, alignment: .leading)

                            Text(row.zoneName)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)

                            Text(row.targetRange)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .padding(.top, Constants.xxs)
            } else {
                Text(emptyMessage)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ZoneSettingsPreviewHost: View {
    private static let previewMaxHR = 180

    @State private var inputText = "\(previewMaxHR)"
    private var sampleRows: [ZoneRowDisplay] {
        HeartRateZone.allCases.map { zone in
            ZoneRowDisplay(
                zoneNumber: zone.name,
                zoneName: zone.label,
                targetRange: zone.bpmRangeLabel(maxHR: Self.previewMaxHR)
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZoneSettings(
                navigationTitle: "Heart Rate Zones",
                inputLabel: Copy.settings.setMaxHR,
                inputPlaceholder: Copy.settings.maxHRPlaceholder,
                inputText: $inputText,
                savedValue: Self.previewMaxHR,
                onSave: {},
                zonesSectionTitle: Copy.settings.heartRateZones,
                emptyMessage: Copy.settings.setMaxHRToViewZones,
                zoneRows: sampleRows
            )
        }
    }
}

#Preview {
    ZoneSettingsPreviewHost()
}

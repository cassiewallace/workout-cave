//
//  HeartRateSettings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import SwiftData
import SwiftUI

struct HeartRateSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    @State private var maxHRText: String = Copy.placeholder.empty

    private var zoneRows: [ZoneRowDisplay] {
        guard let maxHR = userSettings?.maxHR, maxHR > 0 else { return [] }
        return HeartRateZone.allCases.map { zone in
            ZoneRowDisplay(
                zoneNumber: zone.name,
                zoneName: zone.label,
                targetRange: zone.bpmRangeLabel(maxHR: maxHR)
            )
        }
    }

    var body: some View {
        ZoneSettings(
            navigationTitle: Copy.settings.setHeartRateZones,
            inputLabel: Copy.settings.setMaxHR,
            inputPlaceholder: Copy.settings.maxHRPlaceholder,
            inputText: $maxHRText,
            savedValue: userSettings?.maxHR,
            onSave: saveMaxHR,
            zonesSectionTitle: Copy.settings.heartRateZones,
            emptyMessage: Copy.settings.setMaxHRToViewZones,
            zoneRows: zoneRows
        )
        .onAppear {
            if maxHRText.isEmpty, let maxHR = userSettings?.maxHR {
                maxHRText = String(maxHR)
            }
        }
    }

    @MainActor
    private func saveMaxHR() {
        guard let maxHR = Int(maxHRText), maxHR > 0 else { return }

        if let userSettings {
            userSettings.maxHR = maxHR
        } else {
            modelContext.insert(PreviewData.userSettings(maxHR: maxHR))
        }

        try? modelContext.save()
    }
}

private struct HeartRateSettingsPreviewHost: View {
    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(PreviewData.userSettings())
        try? context.save()
        return c
    }()

    var body: some View {
        NavigationStack {
            HeartRateSettings()
        }
        .modelContainer(container)
    }
}

#Preview {
    HeartRateSettingsPreviewHost()
}

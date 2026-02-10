//
//  FTPSettings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import SwiftData
import SwiftUI

struct FTPSettings: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    @State private var ftpText: String = Copy.placeholder.empty

    private var zoneRows: [ZoneRowDisplay] {
        guard let ftp = userSettings?.ftpWatts, ftp > 0 else { return [] }
        return PowerZone.allCases.map { zone in
            ZoneRowDisplay(
                zoneNumber: zone.name,
                zoneName: zone.label,
                targetRange: zone.wattRangeLabel(ftp: ftp)
            )
        }
    }

    var body: some View {
        ZoneSettings(
            navigationTitle: Copy.settings.setPowerZones,
            inputLabel: Copy.settings.setFTP,
            inputPlaceholder: Copy.settings.ftpPlaceholder,
            inputText: $ftpText,
            savedValue: userSettings?.ftpWatts,
            onSave: saveFTP,
            zonesSectionTitle: Copy.settings.powerZones,
            emptyMessage: Copy.settings.setFTPToViewZones,
            zoneRows: zoneRows
        )
        .onAppear {
            if ftpText.isEmpty, let ftp = userSettings?.ftpWatts {
                ftpText = String(ftp)
            }
        }
    }

    @MainActor
    private func saveFTP() {
        guard let ftp = Int(ftpText), ftp > 0 else { return }

        if let userSettings {
            userSettings.ftpWatts = ftp
        } else {
            modelContext.insert(UserSettings(id: "me", ftpWatts: ftp))
        }

        try? modelContext.save()
    }
}

private struct FTPSettingsPreviewHost: View {
    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()

    var body: some View {
        NavigationStack {
            FTPSettings()
        }
        .modelContainer(container)
    }
}

#Preview {
    FTPSettingsPreviewHost()
}

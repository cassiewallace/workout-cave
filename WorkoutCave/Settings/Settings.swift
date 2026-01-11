//
//  Settings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftData
import SwiftUI

struct Settings: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settings: UserSettings?
    @State private var ftp: Int?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set FTP")
                        .font(.title2)
                        .bold()
                    HStack {
                        TextField("FTP", value: $ftp, format: .number)
                            .textFieldStyle(.roundedBorder)
                        Button("Save") {
                            settings?.ftpWatts = ftp
                            try? modelContext.save()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primary)
                    }
                }
                powerZones
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .task {
            settings = try? UserSettingsStore.loadOrCreate(in: modelContext)
            self.ftp = settings?.ftpWatts
        }
    }
    
    var powerZones: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power Zones")
                .font(.title2)
                .bold()

            if let ftp = settings?.ftpWatts, ftp > 0 {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {

                    // Header
                    GridRow {
                        Text("Zone")
                        Text("Name")
                        Text("Target")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Divider().gridCellColumns(3)

                    // Rows
                    ForEach(PowerZone.allCases) { zone in
                        GridRow {
                            Text("Z\(zone.rawValue)")
                                .fontWeight(.semibold)
                                .frame(width: 44, alignment: .leading)

                            Text(zone.name)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)

                            Text(zone.wattRangeLabel(ftp: ftp))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                Text("Set FTP to view zones.")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private struct PowerZoneRow: Identifiable {
        let id: Int
        let zoneNumber: Int
        let name: String
        let watts: String
    }
}

#Preview("FTP set") {
    let container = try! ModelContainer(for: UserSettings.self)
    let context = container.mainContext

    let settings = UserSettings(id: "me", ftpWatts: 250)
    context.insert(settings)

    return NavigationStack {
        Settings()
    }
    .modelContainer(container)
}

#Preview("No FTP set") {
    let container = try! ModelContainer(for: UserSettings.self)
    let context = container.mainContext

    let settings = UserSettings(id: "me", ftpWatts: nil)
    context.insert(settings)

    return NavigationStack {
        Settings()
    }
    .modelContainer(container)
}

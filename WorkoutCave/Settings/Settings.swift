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
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    @State private var ftpText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ftpSection
                powerZones
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if ftpText.isEmpty, let ftp = userSettings?.ftpWatts {
                ftpText = String(ftp)
            }
        }
    }

    private var ftpSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Set FTP")
                .font(.title2)
                .bold()

            HStack {
                TextField("FTP", text: $ftpText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Button("Save") { saveFTP() }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .disabled(Int(ftpText) == nil)
            }
        }
    }

    private var powerZones: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Power Zones")
                .font(.title2)
                .bold()

            if let ftp = userSettings?.ftpWatts, ftp > 0 {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 10) {
                    GridRow {
                        Text("Zone")
                        Text("Name")
                        Text("Target")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    Divider().gridCellColumns(3)

                    ForEach(PowerZone.allCases) { zone in
                        GridRow {
                            Text("Z\(zone.rawValue)")
                                .fontWeight(.semibold)
                                .frame(width: 44, alignment: .leading)

                            Text(zone.label)
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
                    .foregroundStyle(.secondary)
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

#Preview("FTP set") {
    let container = try! ModelContainer(for: UserSettings.self)
    let context = container.mainContext
    context.insert(UserSettings(id: "me", ftpWatts: 250))

    return NavigationStack { Settings() }
        .modelContainer(container)
}

#Preview("No FTP set") {
    let container = try! ModelContainer(for: UserSettings.self)
    let context = container.mainContext
    context.insert(UserSettings(id: "me", ftpWatts: nil))

    return NavigationStack { Settings() }
        .modelContainer(container)
}

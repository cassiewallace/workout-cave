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

    @State private var ftpText: String = Copy.placeholder.empty

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.xl) {
                ftpSection
                powerZones
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Copy.navigationTitle.settings)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if ftpText.isEmpty, let ftp = userSettings?.ftpWatts {
                ftpText = String(ftp)
            }
        }
    }

    private var ftpSection: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(Copy.settings.setFTP)
                .font(.title2)
                .bold()

            HStack {
                TextField(Copy.settings.ftpPlaceholder, text: $ftpText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                Button(Copy.settings.save) { saveFTP() }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .disabled(Int(ftpText) == nil)
            }
        }
    }

    private var powerZones: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(Copy.settings.powerZones)
                .font(.title2)
                .bold()

            if let ftp = userSettings?.ftpWatts, ftp > 0 {
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

                    ForEach(PowerZone.allCases) { zone in
                        GridRow {
                            Text(String(format: Copy.format.zoneNumber, zone.rawValue))
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
                .padding(.top, Constants.xxs)
            } else {
                Text(Copy.settings.setFTPToViewZones)
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

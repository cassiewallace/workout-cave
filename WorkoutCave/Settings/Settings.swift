//
//  Settings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import Foundation
import SwiftData
import SwiftUI

struct Settings: View {
    @EnvironmentObject private var bluetooth: BluetoothManager
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    @State private var ftpText: String = Copy.placeholder.empty

    var body: some View {
        List {
            Section(Copy.settings.devicesSection) {
                BluetoothDialog(bluetooth: bluetooth)
            }
            Section(Copy.settings.ftpSection) {
                ftpSection
                powerZones
            }
            Section(Copy.settings.unitsSection) {
                Picker(Copy.settings.unitsSection, selection: speedUnitBinding) {
                    ForEach(SpeedUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            Section(Copy.settings.legalSection) {
                NavigationLink(Copy.settings.termsButton) {
                    TermsAndConditionsView()
                }
            }
            Section {
                Text("v\(Bundle.main.appVersion)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(Color.brown.opacity(0.3))
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Copy.navigationTitle.settings)
        .navigationBarTitleDisplayMode(.large)
        .listStyle(.insetGrouped)
        .onAppear {
            if ftpText.isEmpty, let ftp = userSettings?.ftpWatts {
                ftpText = String(ftp)
            }
        }
    }

    private var ftpSection: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(Copy.settings.setFTP)
                .font(.title3)
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

    private var speedUnitBinding: Binding<SpeedUnit> {
        Binding(
            get: { userSettings?.speedUnit ?? .mph },
            set: { newValue in
                if let userSettings {
                    userSettings.speedUnit = newValue
                } else {
                    modelContext.insert(UserSettings(id: "me", speedUnitRawValue: newValue.rawValue))
                }
                try? modelContext.save()
            }
        )
    }
}


private struct SettingsPreviewHost: View {
    @StateObject private var bluetooth = BluetoothManager()

    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()

    private let workoutSource: WorkoutSource = {
        let url = Bundle.main.url(forResource: "40-20", withExtension: "zwo")!
        let data = try! Data(contentsOf: url)
        return ZwiftWorkoutSource(id: "jen-intervals", data: data)
    }()

    var body: some View {
        NavigationStack {
            Settings()
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
}

#Preview {
    SettingsPreviewHost()
}


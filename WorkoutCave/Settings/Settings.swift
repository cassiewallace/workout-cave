//
//  Settings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftData
import SwiftUI

struct Settings: View {
    @EnvironmentObject private var bluetooth: BluetoothManager
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    var body: some View {
        List {
            Section(Copy.settings.devicesSection) {
                BluetoothDialog(bluetooth: bluetooth)
            }
            Section(Copy.settings.ftpSection) {
                NavigationLink(Copy.settings.setPowerZones) {
                    FTPSettings()
                }
            }
            Section(Copy.settings.appearanceSection) {
                Picker(Copy.settings.appearanceSection, selection: appAppearanceBinding) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.displayName).tag(appearance)
                    }
                }
                .padding(-Constants.m)
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            Section(Copy.settings.unitsSection) {
                Picker(Copy.settings.unitsSection, selection: speedUnitBinding) {
                    ForEach(SpeedUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
//                .labelsHidden()
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
        .background(Color("AppBackground"))
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Copy.navigationTitle.settings)
        .navigationBarTitleDisplayMode(.large)
        .listStyle(.insetGrouped)
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

    private var appAppearanceBinding: Binding<AppAppearance> {
        Binding(
            get: { userSettings?.appAppearance ?? .system },
            set: { newValue in
                if let userSettings {
                    userSettings.appAppearance = newValue
                } else {
                    modelContext.insert(UserSettings(id: "me", appearanceRawValue: newValue.rawValue))
                }
                try? modelContext.save()
            }
        )
    }
}


extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
}

#Preview {
    NavigationStack {
        Settings()
    }
    .modelContainer(for: UserSettings.self)
    .environmentObject(BluetoothManager())
}


//
//  WorkoutCave.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftData
import SwiftUI

@main
struct WorkoutCave: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [UserSettings.self])
    }
}

private struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRows: [UserSettings]
    @StateObject private var bluetooth = BluetoothManager()
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false
    @State private var bootstrapError: String?

    private var userSettings: UserSettings? {
        settingsRows.first
    }

    var body: some View {
        Group {
            if let userSettings {
                TabView {
                    NavigationStack {
                        WorkoutList()
                    }
                    .tabItem {
                        Label(Copy.tabBar.workouts, systemImage: "bicycle")
                    }
                    NavigationStack {
                        Settings()
                    }
                    .tabItem {
                        Label(Copy.tabBar.settings, systemImage: "person")
                    }
                }
                .environmentObject(bluetooth)
                .sheet(isPresented: introBinding(userSettings: userSettings)) {
                    Onboarding(onDismiss: markIntroSeen)
                }
                .onAppear {
                    let storedValue = userSettings.hasSeenIntro ?? false
                    if storedValue != hasSeenIntro {
                        hasSeenIntro = storedValue
                    }
                }
                .onChange(of: hasSeenIntro) { _, newValue in
                    if (userSettings.hasSeenIntro ?? false) != newValue {
                        userSettings.hasSeenIntro = newValue
                        try? modelContext.save()
                    }
                }
            } else {
                VStack(spacing: Constants.m) {
                    ProgressView()
                    if let bootstrapError {
                        Text(bootstrapError)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.l)
                    }
                }
            }
        }
        .task {
            await ensureUserSettings()
        }
    }

    @MainActor
    private func ensureUserSettings() async {
        guard settingsRows.isEmpty else { return }
        do {
            _ = try UserSettingsStore.loadOrCreate(in: modelContext)
        } catch {
            bootstrapError = error.localizedDescription
        }
    }

    private func introBinding(userSettings: UserSettings) -> Binding<Bool> {
        Binding(
            get: { !hasSeenIntro },
            set: { newValue in
                if !newValue {
                    markIntroSeen()
                }
            }
        )
    }

    private func markIntroSeen() {
        hasSeenIntro = true
        if let userSettings, (userSettings.hasSeenIntro ?? false) != true {
            userSettings.hasSeenIntro = true
            try? modelContext.save()
        }
    }
}

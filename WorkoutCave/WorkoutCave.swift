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

    var body: some View {
        Group {
            if settingsRows.first != nil {
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
                .tint(.primary)
                .environmentObject(bluetooth)
            } else {
                ProgressView()
                    .task {
                        modelContext.insert(UserSettings(id: "me", ftpWatts: nil))
                        try? modelContext.save()
                    }
            }
        }
    }
}

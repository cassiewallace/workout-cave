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

    var body: some View {
        Group {
            if let settings = settingsRows.first {
                TabView {
                    NavigationStack {
                        WorkoutList()
                    }
                    .tabItem {
                        Label("Workouts", systemImage: "bicycle")
                    }
                    NavigationStack {
                        Settings(settings: settings)
                    }
                    .tabItem {
                        Label("Settings", systemImage: "person")
                    }
                }
                .tint(.primary)
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

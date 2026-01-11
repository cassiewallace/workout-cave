//
//  WorkoutCave.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

@main
struct WorkoutCave: App {
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationStack {
                    WorkoutList()
                }
                    .tabItem {
                        Label("Workouts", systemImage: "bicycle")
                    }
                
                NavigationStack {
                    Settings()
                }
                    .tabItem {
                        Label("Settings", systemImage: "person")
                    }
            }
            .tint(.primary)
        }
        .modelContainer(for: [UserSettings.self])
    }
}


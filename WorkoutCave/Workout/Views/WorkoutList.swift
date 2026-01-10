//
//  WorkoutList.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

struct WorkoutList: View {
    // MARK: - Properties

    private let items = WorkoutCatalog.all()
    @State private var workouts: [(id: String, workout: Workout, source: WorkoutSource)] = []

    // MARK: - Body

    var body: some View {
        List {
            Section {
                NavigationLink("Just Ride") {
                    Metrics()
                        .toolbar(.hidden, for: .tabBar)
                }
            }

            Section("Workouts") {
                ForEach(workouts, id: \.id) { item in
                    NavigationLink(item.workout.name) {
                        WorkoutPlayback(workoutSource: item.source)
                            .navigationTitle(item.workout.name)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
        .task {
            workouts = items.compactMap { item in
                guard let workout = try? item.source.loadWorkout() else {
                    return nil
                }
                return (item.id, workout, item.source)
            }
        }
    }
}

#Preview("Workout List", traits: .portrait) {
    WorkoutList()
}

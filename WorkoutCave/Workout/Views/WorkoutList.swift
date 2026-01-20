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
            NavigationLink {
                WorkoutPlayback(workoutSource: JustRideWorkoutSource())
            } label: {
                WorkoutCard(
                    name: Copy.navigationTitle.justRide,
                    description: Copy.workoutList.justRideDescription
                )
            }
                .listRowInsets(
                    .init(
                        top: Constants.xs,
                        leading: Constants.l,
                        bottom: Constants.xs,
                        trailing: Constants.l
                    )
                )
                .listRowSeparator(.hidden)
            workoutList
                .listRowInsets(
                    .init(
                        top: Constants.xs,
                        leading: Constants.l,
                        bottom: Constants.xs,
                        trailing: Constants.l
                    )
                )
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Copy.navigationTitle.workouts)
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
    
    var workoutList: some View {
        ForEach(workouts, id: \.id) { workout in
            NavigationLink {
                WorkoutPlayback(workoutSource: workout.source)
            } label: {
                WorkoutCard(name: workout.workout.name, description: workout.workout.description)
            }
        }
    }
}

#Preview("Workout List", traits: .portrait) {
    WorkoutList()
}

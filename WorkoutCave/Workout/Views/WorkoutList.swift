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
    @State private var workouts: [LoadedWorkout] = []
    @State private var selectedWorkout: LoadedWorkout? = nil

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
            .listRowInsets(.init(top: Constants.xs, leading: Constants.l, bottom: Constants.xs, trailing: Constants.l))
            .listRowSeparator(.hidden)
            
            workoutList
                .listRowInsets(.init(top: Constants.xs, leading: Constants.l, bottom: Constants.xs, trailing: Constants.l))
                .listRowSeparator(.hidden)
        }
        .navigationDestination(item: $selectedWorkout) { workout in
            WorkoutPlayback(workoutSource: workout.source)
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
                return LoadedWorkout(id: item.id, workout: workout, source: item.source)
            }
        }
    }
    
    var workoutList: some View {
        ForEach(workouts) { workout in
            Button {
                selectedWorkout = workout
            } label: {
                WorkoutCard(name: workout.workout.name,
                            description: workout.workout.description)
            }
        }
    }
}

#Preview("Workout List", traits: .portrait) {
    WorkoutList()
}

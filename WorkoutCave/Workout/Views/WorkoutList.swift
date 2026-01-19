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
                Metrics()
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                WorkoutCard(
                    name: Constants.NavigationTitle.justRide,
                    description: Constants.WorkoutList.justRideDescription
                )
            }
                .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
            workoutList
                .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Constants.NavigationTitle.workouts)
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

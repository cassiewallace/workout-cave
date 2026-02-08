//
//  JustRideWorkoutSource.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import Foundation

struct JustRideWorkoutSource: WorkoutSource {
    static let workoutId = Workout.justRideId

    func loadWorkout() throws -> Workout {
        Workout(
            id: Self.workoutId,
            name: Copy.navigationTitle.justRide,
            description: nil,
            intervals: [],
            duration: nil
        )
    }
}


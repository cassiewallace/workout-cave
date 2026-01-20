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
            description: Copy.workoutList.justRideDescription,
            intervals: [
                Workout.Interval(
                    duration: 6 * 60 * 60,
                    name: Copy.navigationTitle.justRide,
                    message: "Ride when ready. Tap Stop when done.",
                    type: .freeRide,
                    powerTarget: nil
                )
            ]
        )
    }
}


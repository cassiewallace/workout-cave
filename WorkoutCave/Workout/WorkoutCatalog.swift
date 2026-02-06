//
//  WorkoutCatalog.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/19/25.
//

import SwiftUI

struct WorkoutItem: Identifiable {
    let id: String
    let source: WorkoutSource
}

enum WorkoutCatalog {
    static func all() -> [WorkoutItem] {
        [
            // Just Ride
            WorkoutItem(
                id: Workout.justRideId,
                source: JustRideWorkoutSource()
            ),
            // Zwift workouts
            WorkoutItem(
                id: Copy.workoutResource.fortyTwenty,
                source: zwift(resource: Copy.workoutResource.fortyTwenty)
            )
        ]
    }

    private static func zwift(resource: String) -> WorkoutSource {
        let url = Bundle.main.url(forResource: resource, withExtension: Copy.fileExtension.zwo)!
        let data = try! Data(contentsOf: url)

        return ZwiftWorkoutSource(
            id: resource,
            data: data
        )
    }

}

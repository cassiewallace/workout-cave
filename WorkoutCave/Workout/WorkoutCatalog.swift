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
            // JSON workouts
            WorkoutItem(
                id: Copy.workoutResource.steadyStateBase,
                source: json(resource: Copy.workoutResource.steadyStateBase)
            ),
            WorkoutItem(
                id: Copy.workoutResource.recoverySpin,
                source: json(resource: Copy.workoutResource.recoverySpin)
            ),
            WorkoutItem(
                id: Copy.workoutResource.powerIntervals3030,
                source: json(resource: Copy.workoutResource.powerIntervals3030)
            ),
            WorkoutItem(
                id: Copy.workoutResource.tempoIntervals9060,
                source: json(resource: Copy.workoutResource.tempoIntervals9060)
            ),
            WorkoutItem(
                id: Copy.workoutResource.progressiveWarmup,
                source: json(resource: Copy.workoutResource.progressiveWarmup)
            ),
            WorkoutItem(
                id: Copy.workoutResource.enduranceBuild,
                source: json(resource: Copy.workoutResource.enduranceBuild)
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

    private static func json(resource: String) -> WorkoutSource {
        JSONWorkoutSource(resourceName: resource)
    }
}

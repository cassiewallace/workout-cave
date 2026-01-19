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
                id: Constants.WorkoutResource.steadyStateBase,
                source: json(resource: Constants.WorkoutResource.steadyStateBase)
            ),
            WorkoutItem(
                id: Constants.WorkoutResource.recoverySpin,
                source: json(resource: Constants.WorkoutResource.recoverySpin)
            ),
            WorkoutItem(
                id: Constants.WorkoutResource.powerIntervals3030,
                source: json(resource: Constants.WorkoutResource.powerIntervals3030)
            ),
            WorkoutItem(
                id: Constants.WorkoutResource.tempoIntervals9060,
                source: json(resource: Constants.WorkoutResource.tempoIntervals9060)
            ),
            WorkoutItem(
                id: Constants.WorkoutResource.progressiveWarmup,
                source: json(resource: Constants.WorkoutResource.progressiveWarmup)
            ),
            WorkoutItem(
                id: Constants.WorkoutResource.enduranceBuild,
                source: json(resource: Constants.WorkoutResource.enduranceBuild)
            ),
            
            // Zwift workouts
            WorkoutItem(
                id: Constants.WorkoutResource.fortyTwenty,
                source: zwift(resource: Constants.WorkoutResource.fortyTwenty)
            )
        ]
    }

    private static func zwift(resource: String) -> WorkoutSource {
        let url = Bundle.main.url(forResource: resource, withExtension: Constants.FileExtension.zwo)!
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

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
            // Zwift workouts
            WorkoutItem(
                id: "40-20",
                source: zwift(resource: "40-20")
            ),

            // JSON workouts
            WorkoutItem(
                id: "steady-state-base",
                source: json(resource: "steady-state-base")
            ),
            WorkoutItem(
                id: "recovery-spin",
                source: json(resource: "recovery-spin")
            ),
            WorkoutItem(
                id: "30-30-power-intervals",
                source: json(resource: "30-30-power-intervals")
            ),
            WorkoutItem(
                id: "90-60-tempo-intervals",
                source: json(resource: "90-60-tempo-intervals")
            ),
            WorkoutItem(
                id: "progressive-warmup",
                source: json(resource: "progressive-warmup")
            ),
            WorkoutItem(
                id: "endurance-build",
                source: json(resource: "endurance-build")
            )
        ]
    }

    private static func zwift(resource: String) -> WorkoutSource {
        let url = Bundle.main.url(forResource: resource, withExtension: "zwo")!
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

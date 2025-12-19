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
            WorkoutItem(
                id: "jen-intervals",
                source: zwift(resource: "jen-intervals")
            ),
            WorkoutItem(
                id: "sample-zwift",
                source: zwift(resource: "sample")
            ),
            WorkoutItem(
                id: "steady-state",
                source: json(resource: "steady-state")
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

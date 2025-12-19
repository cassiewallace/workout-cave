//
//  JSONWorkoutSource.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/19/25.
//

import Foundation

struct JSONWorkoutSource: WorkoutSource {

    let resourceName: String

    func loadWorkout() throws -> Workout {
        let url = Bundle.main.url(forResource: resourceName, withExtension: "json")!
        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(Workout.self, from: data)
    }
}

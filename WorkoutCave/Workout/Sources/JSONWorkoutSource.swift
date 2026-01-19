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
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: Constants.FileExtension.json) else {
            throw NSError(domain: Constants.ErrorDomain.jsonWorkoutSource, code: 1)
        }

        let data = try Data(contentsOf: url)

        do {
            return try JSONDecoder().decode(Workout.self, from: data)
        } catch {
            print(Constants.DebugLog.jsonDecodeErrorPrefix, error)
            throw error
        }
    }
}

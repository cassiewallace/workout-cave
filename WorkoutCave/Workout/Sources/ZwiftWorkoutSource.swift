//
//  ZwiftWorkoutSource.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/19/25.
//

import Foundation

struct ZwiftWorkoutSource: WorkoutSource {

    // MARK: - Properties
    
    let id: String
    let data: Data
    
    // MARK: - Functions

    func loadWorkout() throws -> Workout {
        let parser = ZWOParser()
        guard let workout = parser.parse(data: data) else {
            throw NSError(
                domain: Copy.errorDomain.zwiftWorkoutSource,
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: Copy.errorMessage.couldNotParseZwiftWorkout
                ]
            )
        }
        return workout
    }
}

//
//  NetworkWorkoutSource.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation

struct NetworkWorkoutSource: WorkoutSource {
    let workout: Workout

    func loadWorkout() throws -> Workout {
        workout
    }
}

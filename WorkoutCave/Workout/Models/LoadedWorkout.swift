//
//  LoadedWorkout.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import Foundation

struct LoadedWorkout: Identifiable, Hashable {
    let id: String
    let workout: Workout
    let source: WorkoutSource
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LoadedWorkout, rhs: LoadedWorkout) -> Bool {
        lhs.id == rhs.id
    }
}


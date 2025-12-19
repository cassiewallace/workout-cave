//
//  Workout.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

// MARK: - Protocols

protocol WorkoutSource {
    func loadWorkout() throws -> Workout
}

struct Workout: Identifiable, Codable {
    // MARK: - Properties
    
    let id: String
    let name: String
    let intervals: [Interval]
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }

    init(
        id: String,
        name: String,
        intervals: [Interval]
    ) {
        self.id = id
        self.name = name
        self.intervals = intervals
    }
}

extension Workout {
    struct Interval: Codable {
        // MARK: - Enumerations
        
        enum IntervalType: String, Codable {
            case warmup
            case steadyState
            case intervalOn
            case intervalOff
            case recovery
            case cooldown
            case freeRide
        }
        
        // MARK: - Properties
        
        let duration: TimeInterval // in seconds
        let name: String
        let message: String?
        let type: IntervalType
    }
}


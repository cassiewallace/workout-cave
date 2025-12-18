//
//  Workout.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

struct Workout {
    // MARK: - Properties
    
    let name: String
    let intervals: [Interval]
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }
}

extension Workout {
    struct Interval {
        // MARK: - Properties
        
        let duration: TimeInterval // in seconds
        let name: String
    }
}


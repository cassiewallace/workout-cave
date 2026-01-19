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
    let description: String
    let intervals: [Interval]
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }

    init(
        id: String,
        name: String,
        description: String,
        intervals: [Interval]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.intervals = intervals
    }
}

extension Workout {
    struct Interval: Codable {
        // MARK: - Enumerations
        
        enum CodingKeys: String, CodingKey {
            case duration
            case name
            case message
            case type
            case powerTarget
        }
        
        enum IntervalType: String, Codable {
            case warmup
            case steadyState
            case intervalOn
            case intervalOff
            case recovery
            case cooldown
            case freeRide
        }
        
        struct PowerTarget: Codable {
            let lowerBound: Double?
            let upperBound: Double?

            func zones(using zones: [PowerZone] = PowerZone.allCases) -> [PowerZone] {
                guard let lowerBound, let upperBound else { return [] }

                // Some sources can provide reversed bounds. Avoid crashing on
                // `ClosedRange` construction by normalizing first.
                let lo = min(lowerBound, upperBound)
                let hi = max(lowerBound, upperBound)
                let targetRange = lo ... hi
                return zones.filter { targetRange.overlaps($0.range) }
            }
        }
        
        // MARK: - Properties
        
        let id: UUID
        let duration: TimeInterval
        let name: String
        let message: String?
        let type: IntervalType
        let powerTarget: PowerTarget?
        
        // MARK: - Inits

        init(
            id: UUID = UUID(),
            duration: TimeInterval,
            name: String,
            message: String? = nil,
            type: IntervalType,
            powerTarget: PowerTarget? = nil
        ) {
            self.id = id
            self.duration = duration
            self.name = name
            self.message = message
            self.type = type
            self.powerTarget = powerTarget
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.id = UUID()
            self.duration = try container.decode(TimeInterval.self, forKey: .duration)
            self.name = try container.decode(String.self, forKey: .name)
            self.message = try container.decodeIfPresent(String.self, forKey: .message)
            self.type = try container.decode(IntervalType.self, forKey: .type)
            self.powerTarget = try container.decodeIfPresent(PowerTarget.self, forKey: .powerTarget)
        }
    }
}

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

    static let justRideId = "just-ride"

    let id: String
    let name: String
    let description: String?
    let intervals: [Interval]
    /// For interval-less workouts: fixed duration in seconds. Nil = open-ended.
    let duration: TimeInterval?
    /// Metrics to show during playback. Nil = default set.
    let metrics: [Metric]?
    /// Metrics to show when finished. Nil = default ([.averagePower, .heartRate]).
    let finishedMetrics: [Metric]?

    var isJustRide: Bool {
        id == Self.justRideId
    }

    var hasIntervals: Bool {
        !intervals.isEmpty
    }

    var totalDuration: TimeInterval {
        if hasIntervals {
            return intervals.reduce(0) { $0 + $1.duration }
        }
        return duration ?? 0
    }

    init(
        id: String,
        name: String,
        description: String?,
        intervals: [Interval],
        duration: TimeInterval? = nil,
        metrics: [Metric]? = nil,
        finishedMetrics: [Metric]? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.intervals = intervals
        self.duration = duration
        self.metrics = metrics
        self.finishedMetrics = finishedMetrics
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

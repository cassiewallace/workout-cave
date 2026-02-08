//
//  WorkoutAPI.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation
import Supabase

struct WorkoutAPI {
    let client: SupabaseClient

    init(client: SupabaseClient = NetworkClient.shared.client) {
        self.client = client
    }

    func fetchWorkoutSummaries() async throws -> [WorkoutSummary] {
        let rows: [WorkoutSummaryRow] = try await client
            .from("workouts")
            .select("id,name,description")
            .order("id")
            .execute()
            .value
        return rows.map {
            WorkoutSummary(
                id: $0.id,
                name: $0.name,
                description: $0.description
            )
        }
    }

    func fetchWorkout(id: Int) async throws -> Workout {
        let rows: [WorkoutRow] = try await client
            .from("workouts")
            .select("id,name,description,duration,metrics,finished_metrics,intervals(name,duration,message,type,power_lower,power_upper,order_index)")
            .eq("id", value: id)
            .execute()
            .value

        guard let row = rows.first else {
            throw WorkoutAPIError.notFound
        }

        return row.toWorkout()
    }
}

enum WorkoutAPIError: Error {
    case notFound
}

struct WorkoutSummary: Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
}

struct WorkoutSummaryRow: Decodable {
    let id: Int
    let name: String
    let description: String?
}

struct WorkoutRow: Decodable {
    let id: Int
    let name: String
    let description: String?
    let duration: Int?
    let metrics: [String]?
    let finishedMetrics: [String]?
    let intervals: [IntervalRow]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, duration, intervals
        case metrics
        case finishedMetrics = "finished_metrics"
    }

    func toWorkout() -> Workout {
        let sortedIntervals = (intervals ?? []).sorted {
            ($0.orderIndex ?? Int.max) < ($1.orderIndex ?? Int.max)
        }

        let mappedIntervals = sortedIntervals.map { row in
            Workout.Interval(
                duration: TimeInterval(row.duration),
                name: row.name,
                message: row.message,
                type: Workout.Interval.IntervalType(rawValue: row.type ?? "") ?? .steadyState,
                powerTarget: row.powerTarget
            )
        }

        let mappedMetrics = (metrics ?? []).compactMap { Metric(rawValue: $0) }
        let mappedFinishedMetrics = (finishedMetrics ?? []).compactMap { Metric(rawValue: $0) }

        return Workout(
            id: String(id),
            name: name,
            description: description,
            intervals: mappedIntervals,
            duration: duration.map { TimeInterval($0) },
            metrics: mappedMetrics.isEmpty ? nil : mappedMetrics,
            finishedMetrics: mappedFinishedMetrics.isEmpty ? nil : mappedFinishedMetrics
        )
    }
}

struct IntervalRow: Decodable {
    let name: String
    let duration: Int
    let message: String?
    let type: String?
    let powerLower: Double?
    let powerUpper: Double?
    let orderIndex: Int?

    var powerTarget: Workout.Interval.PowerTarget? {
        guard powerLower != nil || powerUpper != nil else { return nil }
        return Workout.Interval.PowerTarget(lowerBound: powerLower, upperBound: powerUpper)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case duration
        case message
        case type
        case powerLower = "power_lower"
        case powerUpper = "power_upper"
        case orderIndex = "order_index"
    }
}

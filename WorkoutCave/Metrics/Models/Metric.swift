//
//  Metric.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation

enum Metric: String, Hashable, CaseIterable {
    case averagePower = "Average Power"
    case targetZone = "Target Zone"
    case zone
    case power
    case cadence
    case speed
    case heartRate = "Heart Rate"
}

extension Metric: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        // Try raw value first (e.g., "Average Power")
        if let metric = Metric(rawValue: value) {
            self = metric
            return
        }
        
        // Fall back to camelCase database format for multi-word cases
        switch value {
        case "averagePower":
            self = .averagePower
        case "targetZone":
            self = .targetZone
        case "heartRate":
            self = .heartRate
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot decode Metric from value: \(value)"
                )
            )
        }
    }
}


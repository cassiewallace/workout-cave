//
//  Metric.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation

enum Metric: String, Hashable, Codable, CaseIterable {
    case averagePower = "Average Power"
    case targetZone = "Target Zone"
    case zone
    case power
    case cadence
    case speed
    case heartRate = "Heart Rate"
}

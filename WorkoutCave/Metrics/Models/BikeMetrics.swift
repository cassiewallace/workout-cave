//
//  BikeMetrics.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import Foundation

struct BikeMetrics: Equatable {
    var speedKph: Double?        // 0.01 km/h units from FTMS
    var cadenceRpm: Double?      // 0.5 rpm units from FTMS
    var powerWatts: Int?         // Int16 watts from FTMS
    var heartRateBpm: Int?       // UInt8 bpm from FTMS (often nil if 0)
}

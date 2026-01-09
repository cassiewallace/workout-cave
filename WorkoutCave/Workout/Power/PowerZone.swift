//
//  PowerZone.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/23/25.
//

struct PowerZone: Identifiable, Equatable {
    let id: Int
    let name: String
    let lowerBound: Double? // fraction of FTP
    let upperBound: Double?
}

extension PowerZone {
    func contains(_ value: Double) -> Bool {
        if let lower = lowerBound, value < lower { return false }
        if let upper = upperBound, value > upper { return false }
        return true
    }
}

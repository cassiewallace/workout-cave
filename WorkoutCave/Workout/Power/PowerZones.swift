//
//  PowerZones.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/23/25.
//

enum PowerZones {
    static let standard: [PowerZone] = [
        PowerZone(id: 1, name: "Recovery",     lowerBound: nil,   upperBound: 0.55),
        PowerZone(id: 2, name: "Endurance",    lowerBound: 0.56,  upperBound: 0.75),
        PowerZone(id: 3, name: "Tempo",        lowerBound: 0.76,  upperBound: 0.90),
        PowerZone(id: 4, name: "Threshold",    lowerBound: 0.91,  upperBound: 1.05),
        PowerZone(id: 5, name: "VO₂ Max",      lowerBound: 1.06,  upperBound: 1.20),
        PowerZone(id: 6, name: "Anaerobic",    lowerBound: 1.21,  upperBound: 1.50),
        PowerZone(id: 7, name: "Neuromuscular",lowerBound: 1.51,  upperBound: nil)
    ]
}

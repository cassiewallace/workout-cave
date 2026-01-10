//
//  PowerZone.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/23/25.
//

enum PowerZone: Int, CaseIterable, Identifiable {
    case recovery = 1
    case endurance
    case tempo
    case threshold
    case vo2Max
    case anaerobic
    case neuromuscular

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .recovery:        return "Recovery"
        case .endurance:       return "Endurance"
        case .tempo:           return "Tempo"
        case .threshold:       return "Threshold"
        case .vo2Max:          return "VO₂ Max"
        case .anaerobic:       return "Anaerobic"
        case .neuromuscular:   return "Neuromuscular"
        }
    }

    /// Fraction of FTP
    var range: ClosedRange<Double> {
        switch self {
        case .recovery:        return 0.0 ... 0.55
        case .endurance:       return 0.56 ... 0.75
        case .tempo:           return 0.76 ... 0.90
        case .threshold:       return 0.91 ... 1.05
        case .vo2Max:          return 1.06 ... 1.20
        case .anaerobic:       return 1.21 ... 1.50
        case .neuromuscular:   return 1.51 ... .infinity
        }
    }
}

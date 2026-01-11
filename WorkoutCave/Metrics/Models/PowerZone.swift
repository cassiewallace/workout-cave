//
//  PowerZone.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/23/25.
//

import Foundation

enum PowerZone: Int, CaseIterable, Identifiable {
    case recovery = 1
    case endurance
    case tempo
    case threshold
    case vo2Max
    case anaerobic
    case neuromuscular

    var id: Int { rawValue }

    // MARK: - Display

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

    /// Fraction of FTP (e.g. 0.75 = 75% FTP)
    var range: ClosedRange<Double> {
        switch self {
        case .recovery:        return 0.00 ... 0.55
        case .endurance:       return 0.56 ... 0.75
        case .tempo:           return 0.76 ... 0.90
        case .threshold:       return 0.91 ... 1.05
        case .vo2Max:          return 1.06 ... 1.20
        case .anaerobic:       return 1.21 ... 1.50
        case .neuromuscular:   return 1.51 ... .infinity
        }
    }

    // MARK: - Helpers

    func wattRange(for ftp: Double) -> ClosedRange<Double> {
        (range.lowerBound * ftp) ... (range.upperBound * ftp)
    }

    func contains(watts: Double, ftp: Double) -> Bool {
        wattRange(for: ftp).contains(watts)
    }

    static func zone(for watts: Double, ftp: Double) -> PowerZone? {
        PowerZone.allCases.first { $0.contains(watts: watts, ftp: ftp) }
    }
}

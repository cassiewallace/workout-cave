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

    func wattRange(ftp: Int) -> (lower: Int, upper: Int?) {
        let ftpD = Double(ftp)
        let lower = Int((ftpD * range.lowerBound).rounded())

        guard range.upperBound.isFinite else {
            return (lower: lower, upper: nil)
        }

        let upper = Int((ftpD * range.upperBound).rounded())
        return (lower: lower, upper: upper)
    }

    func wattRangeLabel(ftp: Int) -> String {
        let b = wattRange(ftp: ftp)
        if let upper = b.upper {
            return "\(b.lower)–\(upper) W"
        } else {
            return "\(b.lower)+ W"
        }
    }
}

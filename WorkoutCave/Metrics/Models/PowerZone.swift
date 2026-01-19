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
        String(format: Copy.format.zoneNumber, id)
    }
    
    var label: String {
        switch self {
        case .recovery:        return Copy.powerZone.label.recovery
        case .endurance:       return Copy.powerZone.label.endurance
        case .tempo:           return Copy.powerZone.label.tempo
        case .threshold:       return Copy.powerZone.label.threshold
        case .vo2Max:          return Copy.powerZone.label.vo2Max
        case .anaerobic:       return Copy.powerZone.label.anaerobic
        case .neuromuscular:   return Copy.powerZone.label.neuromuscular
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
    
    // MARK: - Internal Helpers
    
    /// Returns a human-readable watt range label for this zone based on FTP.
    ///
    /// Examples:
    /// - "120–160 W"
    /// - "260+ W" (for zones with no upper bound)
    ///
    /// - Parameter ftp: Athlete’s functional threshold power in watts.
    /// - Returns: A formatted string suitable for UI display.
    func wattRangeLabel(ftp: Int) -> String {
        let b = wattRange(ftp: ftp)
        if let upper = b.upper {
            return String(b.lower)
            + Copy.units.wattsRangeSeparator
            + String(upper)
            + Copy.units.wattsSuffix
        } else {
            return String(b.lower) + Copy.units.wattsPlusSuffix
        }
    }
    
    /// Returns the zone that contains `watts` for a given FTP.
    /// - Parameters:
    ///   - watts: Current power in watts.
    ///   - ftp: Athlete FTP in watts.
    /// - Returns: The matching `PowerZone`, or nil if FTP is invalid.
    static func zone(for watts: Int?, ftp: Int) -> PowerZone? {
        guard let watts, ftp > 0 else { return nil }

        let fraction = Double(watts) / Double(ftp)
        return Self.allCases.first { $0.range.contains(fraction) }
    }

    // MARK: - UI Helpers

    /// Convenience helper for UI: returns a zone name like "Z3", or a friendly
    /// fallback when watts / FTP are unavailable.
    static func zoneNameLabel(for watts: Int?, ftp: Int?) -> String {
        guard let watts else { return Copy.placeholder.missingValue }
        guard let ftp, ftp > 0 else { return Copy.powerZone.setFTP }
        return Self.zone(for: watts, ftp: ftp)?.name ?? Copy.placeholder.missingValue
    }
    
    // MARK: - Private Helpers
    
    /// Calculates the lower and upper watt bounds for this zone from FTP.
    ///
    /// The bounds are derived from the zone’s fractional FTP range and rounded
    /// to the nearest whole watt. Zones without an upper bound return `nil`
    /// for the upper value.
    ///
    /// - Parameter ftp: Athlete’s functional threshold power in watts.
    /// - Returns: A tuple containing the lower bound and an optional upper bound.
    private func wattRange(ftp: Int) -> (lower: Int, upper: Int?) {
        let ftpD = Double(ftp)
        let lower = Int((ftpD * range.lowerBound).rounded())
        
        guard range.upperBound.isFinite else {
            return (lower: lower, upper: nil)
        }
        
        let upper = Int((ftpD * range.upperBound).rounded())
        return (lower: lower, upper: upper)
    }
}

extension Array where Element == PowerZone {
    var zoneLabel: String? {
        guard let first, let last else { return nil }

        if first == last {
            return first.name
        } else {
            return first.name + Copy.separator.hyphen + last.name
        }
    }
}

//
//  HeartRateZone.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import Foundation
import SwiftUI

/// Standard 5-zone heart rate model as percentage of maximum heart rate.
enum HeartRateZone: Int, CaseIterable, Identifiable {
    case zone1 = 1  // 50–60%
    case zone2 = 2  // 60–70%
    case zone3 = 3  // 70–80%
    case zone4 = 4  // 80–90%
    case zone5 = 5  // 90–100%

    var id: Int { rawValue }

    // MARK: - Display

    var name: String {
        String(format: Copy.format.zoneNumber, id)
    }

    var label: String {
        switch self {
        case .zone1: return Copy.heartRateZone.label.zone1
        case .zone2: return Copy.heartRateZone.label.zone2
        case .zone3: return Copy.heartRateZone.label.zone3
        case .zone4: return Copy.heartRateZone.label.zone4
        case .zone5: return Copy.heartRateZone.label.zone5
        }
    }

    /// Fraction of max HR (e.g. 0.60 = 60% max HR)
    var range: ClosedRange<Double> {
        switch self {
        case .zone1: return 0.50 ... 0.60
        case .zone2: return 0.60 ... 0.70
        case .zone3: return 0.70 ... 0.80
        case .zone4: return 0.80 ... 0.90
        case .zone5: return 0.90 ... 1.00
        }
    }
    
    var color: Color {
        switch self {
        case .zone1:
            return Color("NeonCyan")
        case .zone2:
            return Color("NeonGreen")
        case .zone3:
            return Color("NeonYellow")
        case .zone4:
            return Color("NeonOrange")
        case .zone5:
            return Color("NeonRed")
        }
    }

    // MARK: - Internal Helpers

    /// Returns a human-readable BPM range label for this zone based on max HR.
    func bpmRangeLabel(maxHR: Int) -> String {
        let b = bpmRange(maxHR: maxHR)
        return String(b.lower)
            + Copy.units.bpmRangeSeparator
            + String(b.upper)
            + Copy.units.bpmSuffix
    }

    /// Returns the zone that contains `bpm` for a given max HR.
    static func zone(for bpm: Int?, maxHR: Int) -> HeartRateZone? {
        guard let bpm, maxHR > 0 else { return nil }
        let fraction = Double(bpm) / Double(maxHR)
        return Self.allCases.first { $0.range.contains(fraction) }
    }

    // MARK: - UI Helpers

    static func zoneNameLabel(for bpm: Int?, maxHR: Int?) -> String {
        guard let bpm else { return Copy.placeholder.missingValue }
        guard let maxHR, maxHR > 0 else { return Copy.settings.setMaxHR }
        return Self.zone(for: bpm, maxHR: maxHR)?.name ?? Copy.placeholder.missingValue
    }

    // MARK: - Private Helpers

    private func bpmRange(maxHR: Int) -> (lower: Int, upper: Int) {
        let maxHRD = Double(maxHR)
        let lower = Int((maxHRD * range.lowerBound).rounded())
        let upper = Int((maxHRD * range.upperBound).rounded())
        return (lower: lower, upper: upper)
    }
}

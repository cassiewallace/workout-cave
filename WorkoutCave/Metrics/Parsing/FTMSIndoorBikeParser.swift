//
//  FTMSIndoorBikeParser.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import Foundation

/// Parses FTMS "Indoor Bike Data" (UUID 0x2AD2).
/// Payload layout:
/// [Flags: UInt16 LE]
/// [Instantaneous Speed: UInt16 LE]   // 0.01 km/h, effectively always present
/// Optional fields follow, in spec order, gated by flags.
struct FTMSIndoorBikeParser {

    func parse(_ data: Data) -> BikeMetrics? {
        // Minimum: flags (2) + speed (2)
        guard data.count >= 4 else { return nil }

        var index = 0

        func readUInt8() -> UInt8 {
            defer { index += 1 }
            return data[index]
        }

        func readUInt16() -> UInt16 {
            defer { index += 2 }
            return UInt16(data[index]) | (UInt16(data[index + 1]) << 8)
        }

        func readInt16() -> Int16 {
            Int16(bitPattern: readUInt16())
        }

        let flags = readUInt16()

        // Instantaneous speed (0.01 km/h)
        let rawSpeed = readUInt16()
        var metrics = BikeMetrics()
        metrics.speedKph = Double(rawSpeed) / 100.0

        // Bit 2: Instantaneous cadence (0.5 rpm)
        if (flags & 0x0004) != 0, index + 1 < data.count {
            let rawCadence = readUInt16()
            metrics.cadenceRpm = Double(rawCadence) / 2.0
        }

        // Bit 6: Instantaneous power (watts, Int16)
        if (flags & 0x0040) != 0, index + 1 < data.count {
            metrics.powerWatts = Int(readInt16())
        }

        // Bit 9: Heart rate (UInt8 bpm)
        if (flags & 0x0200) != 0, index < data.count {
            let hr = Int(readUInt8())
            metrics.heartRateBpm = (hr == 0) ? nil : hr
        }

        return metrics
    }
}

//
//  PowerZoneTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class PowerZoneTests: XCTestCase {

    func testZone_forWattsAndFTP_returnsMatchingZone() {
        // 200 W at 250 FTP = 0.8 → tempo (0.76–0.90)
        let zone = PowerZone.zone(for: 200, ftp: 250)
        XCTAssertEqual(zone, .tempo)
    }

    func testZone_forThresholdFraction_returnsThreshold() {
        // 250 W at 250 FTP = 1.0 → threshold (0.91–1.05)
        let zone = PowerZone.zone(for: 250, ftp: 250)
        XCTAssertEqual(zone, .threshold)
    }

    func testZone_forNilWatts_returnsNil() {
        XCTAssertNil(PowerZone.zone(for: nil, ftp: 250))
    }

    func testZone_forZeroFTP_returnsNil() {
        XCTAssertNil(PowerZone.zone(for: 200, ftp: 0))
    }

    func testZone_forNegativeFTP_returnsNil() {
        XCTAssertNil(PowerZone.zone(for: 200, ftp: -100))
    }

    func testWattRangeLabel_finiteRange_returnsFormattedRange() {
        // Tempo 0.76–0.90 at 200 FTP → 152–180 W
        let label = PowerZone.tempo.wattRangeLabel(ftp: 200)
        XCTAssertTrue(label.hasPrefix("152"))
        XCTAssertTrue(label.contains("180"))
        XCTAssertTrue(label.hasSuffix(" W"))
    }

    func testWattRangeLabel_noUpperBound_returnsPlusSuffix() {
        // Neuromuscular has no upper bound
        let label = PowerZone.neuromuscular.wattRangeLabel(ftp: 250)
        XCTAssertTrue(label.hasSuffix("+ W"))
        XCTAssertTrue(label.contains("378")) // lower bound
    }
}

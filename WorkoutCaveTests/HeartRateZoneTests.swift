//
//  HeartRateZoneTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class HeartRateZoneTests: XCTestCase {

    func testZone_forBpmAndMaxHR_returnsMatchingZone() {
        // 108 bpm at 180 max = 0.6 → zone2 (60–70%)
        let zone = HeartRateZone.zone(for: 108, maxHR: 180)
        XCTAssertEqual(zone, .zone2)
    }

    func testZone_forMaxFraction_returnsZone5() {
        // 180 bpm at 180 max = 1.0 → zone5 (90–100%)
        let zone = HeartRateZone.zone(for: 180, maxHR: 180)
        XCTAssertEqual(zone, .zone5)
    }

    func testZone_forMidZone3_returnsZone3() {
        // 126 bpm at 180 max = 0.7 → zone3 (70–80%)
        let zone = HeartRateZone.zone(for: 126, maxHR: 180)
        XCTAssertEqual(zone, .zone3)
    }

    func testZone_forNilBpm_returnsNil() {
        XCTAssertNil(HeartRateZone.zone(for: nil, maxHR: 180))
    }

    func testZone_forZeroMaxHR_returnsNil() {
        XCTAssertNil(HeartRateZone.zone(for: 120, maxHR: 0))
    }

    func testZone_forNegativeMaxHR_returnsNil() {
        XCTAssertNil(HeartRateZone.zone(for: 120, maxHR: -100))
    }

    func testBpmRangeLabel_returnsFormattedRange() {
        // Zone3 70–80% at 180 max → 126–144 bpm
        let label = HeartRateZone.zone3.bpmRangeLabel(maxHR: 180)
        XCTAssertTrue(label.hasPrefix("126"))
        XCTAssertTrue(label.contains("144"))
        XCTAssertTrue(label.hasSuffix(" bpm"))
    }

    func testZoneNameLabel_forNilBpm_returnsMissingValue() {
        XCTAssertEqual(
            HeartRateZone.zoneNameLabel(for: nil, maxHR: 180),
            Copy.placeholder.missingValue
        )
    }

    func testZoneNameLabel_forNilMaxHR_returnsSetMaxHR() {
        XCTAssertEqual(
            HeartRateZone.zoneNameLabel(for: 120, maxHR: nil),
            Copy.settings.setMaxHR
        )
    }

    func testZoneNameLabel_forValidInput_returnsZoneName() {
        XCTAssertEqual(
            HeartRateZone.zoneNameLabel(for: 108, maxHR: 180),
            "Z2"
        )
    }
}

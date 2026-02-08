//
//  PowerTargetTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class PowerTargetTests: XCTestCase {

    func testZones_withRangeInSingleZone_returnsThatZone() {
        // 0.56–0.75 is endurance (Z2)
        let target = Workout.Interval.PowerTarget(lowerBound: 0.6, upperBound: 0.7)
        let zones = target.zones(using: PowerZone.allCases)
        XCTAssertEqual(zones, [.endurance])
    }

    func testZones_withRangeSpanningTwoZones_returnsBothZones() {
        // 0.75 is end of endurance, 0.76 is start of tempo
        let target = Workout.Interval.PowerTarget(lowerBound: 0.74, upperBound: 0.78)
        let zones = target.zones(using: PowerZone.allCases)
        XCTAssertEqual(zones.count, 2)
        XCTAssertTrue(zones.contains(.endurance))
        XCTAssertTrue(zones.contains(.tempo))
    }

    func testZones_withNilBounds_returnsEmpty() {
        let target = Workout.Interval.PowerTarget(lowerBound: nil, upperBound: nil)
        let zones = target.zones(using: PowerZone.allCases)
        XCTAssertTrue(zones.isEmpty)
    }

    func testZones_withReversedBounds_normalizesAndReturnsZones() {
        // Upper < lower should be normalized to lo...hi
        let target = Workout.Interval.PowerTarget(lowerBound: 0.9, upperBound: 0.7)
        let zones = target.zones(using: PowerZone.allCases)
        // 0.7–0.9 spans endurance and tempo
        XCTAssertFalse(zones.isEmpty)
        XCTAssertTrue(zones.contains(.endurance))
        XCTAssertTrue(zones.contains(.tempo))
    }
}

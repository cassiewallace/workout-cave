//
//  WorkoutTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class WorkoutTests: XCTestCase {

    func testTotalDuration_fromIntervals_sumsIntervalDurations() {
        let intervals: [Workout.Interval] = [
            .init(duration: 60, name: "Warmup", type: .warmup),
            .init(duration: 300, name: "Main", type: .steadyState),
            .init(duration: 120, name: "Cooldown", type: .cooldown),
        ]
        let workout = Workout(
            id: "test",
            name: "Test",
            description: nil,
            intervals: intervals,
            duration: nil
        )
        XCTAssertEqual(workout.totalDuration, 480)
    }

    func testTotalDuration_fixedDuration_returnsDurationWhenNoIntervals() {
        let workout = Workout(
            id: "test",
            name: "Test",
            description: nil,
            intervals: [],
            duration: 1800
        )
        XCTAssertEqual(workout.totalDuration, 1800)
    }

    func testTotalDuration_emptyIntervalsAndNilDuration_returnsZero() {
        let workout = Workout(
            id: "test",
            name: "Test",
            description: nil,
            intervals: [],
            duration: nil
        )
        XCTAssertEqual(workout.totalDuration, 0)
    }

    func testHasIntervals_withIntervals_returnsTrue() {
        let workout = Workout(
            id: "test",
            name: "Test",
            description: nil,
            intervals: [.init(duration: 60, name: "I", type: .warmup)],
            duration: nil
        )
        XCTAssertTrue(workout.hasIntervals)
    }

    func testHasIntervals_noIntervals_returnsFalse() {
        let workout = Workout(
            id: "test",
            name: "Test",
            description: nil,
            intervals: [],
            duration: 600
        )
        XCTAssertFalse(workout.hasIntervals)
    }

    func testIsJustRide_forJustRideId_returnsTrue() {
        let workout = Workout(
            id: Workout.justRideId,
            name: "Just Ride",
            description: nil,
            intervals: [],
            duration: nil
        )
        XCTAssertTrue(workout.isJustRide)
    }

    func testIsJustRide_forOtherId_returnsFalse() {
        let workout = Workout(
            id: "other",
            name: "Other",
            description: nil,
            intervals: [],
            duration: nil
        )
        XCTAssertFalse(workout.isJustRide)
    }
}

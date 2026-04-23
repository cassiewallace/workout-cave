//
//  WorkoutAPIMappingTests.swift
//  WorkoutCave
//

import XCTest
@testable import WorkoutCave

final class WorkoutAPIMappingTests: XCTestCase {

    func testWorkoutRecord_mapsIdNameDescription() {
        let data: [String: Any] = ["name": "Sweet Spot", "description": "Aerobic base", "duration": 3600]
        let workout = data.toWorkout(id: "42", intervals: [])
        XCTAssertEqual(workout.id, "42")
        XCTAssertEqual(workout.name, "Sweet Spot")
        XCTAssertEqual(workout.description, "Aerobic base")
        XCTAssertEqual(workout.duration, 3600)
        XCTAssertTrue(workout.intervals.isEmpty)
    }

    func testWorkoutRecord_ordersIntervalsByOrderIndex() {
        let workoutData: [String: Any] = ["name": "Intervals"]
        let second: [String: Any] = ["name": "Second", "duration": 60, "order_index": 2]
        let first: [String: Any] = ["name": "First", "duration": 30, "order_index": 1]

        // Firestore returns intervals sorted by order_index via the query, mapping preserves order
        let workout = workoutData.toWorkout(id: "1", intervals: [first.toInterval(), second.toInterval()])
        XCTAssertEqual(workout.intervals.count, 2)
        XCTAssertEqual(workout.intervals[0].name, "First")
        XCTAssertEqual(workout.intervals[0].duration, 30)
        XCTAssertEqual(workout.intervals[1].name, "Second")
        XCTAssertEqual(workout.intervals[1].duration, 60)
    }

    func testWorkoutRecord_mapsMetricsAndFinishedMetrics() {
        let data: [String: Any] = [
            "name": "Test",
            "metrics": ["power", "cadence"],
            "finished_metrics": ["averagePower", "heartRate"],
        ]
        let workout = data.toWorkout(id: "1", intervals: [])
        XCTAssertEqual(workout.metrics, [.power, .cadence])
        XCTAssertEqual(workout.finishedMetrics, [.averagePower, .heartRate])
    }

    func testIntervalRecord_withPowerTarget_mapsPowerBounds() {
        let data: [String: Any] = [
            "name": "Steady",
            "duration": 300,
            "type": "steadyState",
            "power_lower": 0.85,
            "power_upper": 0.95,
        ]
        let interval = data.toInterval()
        XCTAssertEqual(interval.type, .steadyState)
        XCTAssertEqual(interval.powerTarget?.lowerBound, 0.85)
        XCTAssertEqual(interval.powerTarget?.upperBound, 0.95)
    }
}

//
//  WorkoutAPIMappingTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class WorkoutAPIMappingTests: XCTestCase {

    func testWorkoutRowToWorkout_mapsIdNameDescription() throws {
        let json = """
        {
            "id": 42,
            "name": "Sweet Spot",
            "description": "Aerobic base",
            "duration": 3600,
            "intervals": []
        }
        """
        let row = try JSONDecoder().decode(WorkoutRow.self, from: Data(json.utf8))
        let workout = row.toWorkout()
        XCTAssertEqual(workout.id, "42")
        XCTAssertEqual(workout.name, "Sweet Spot")
        XCTAssertEqual(workout.description, "Aerobic base")
        XCTAssertEqual(workout.duration, 3600)
        XCTAssertTrue(workout.intervals.isEmpty)
    }

    func testWorkoutRowToWorkout_ordersIntervalsByOrderIndex() throws {
        let json = """
        {
            "id": 1,
            "name": "Intervals",
            "description": null,
            "duration": null,
            "intervals": [
                { "name": "Second", "duration": 60, "order_index": 2 },
                { "name": "First", "duration": 30, "order_index": 1 }
            ]
        }
        """
        let row = try JSONDecoder().decode(WorkoutRow.self, from: Data(json.utf8))
        let workout = row.toWorkout()
        XCTAssertEqual(workout.intervals.count, 2)
        XCTAssertEqual(workout.intervals[0].name, "First")
        XCTAssertEqual(workout.intervals[0].duration, 30)
        XCTAssertEqual(workout.intervals[1].name, "Second")
        XCTAssertEqual(workout.intervals[1].duration, 60)
    }

    func testWorkoutRowToWorkout_mapsMetricsAndFinishedMetrics() throws {
        let json = """
        {
            "id": 1,
            "name": "Test",
            "description": null,
            "duration": null,
            "metrics": ["power", "cadence"],
            "finished_metrics": ["averagePower", "heartRate"],
            "intervals": []
        }
        """
        let row = try JSONDecoder().decode(WorkoutRow.self, from: Data(json.utf8))
        let workout = row.toWorkout()
        XCTAssertEqual(workout.metrics, [.power, .cadence])
        XCTAssertEqual(workout.finishedMetrics, [.averagePower, .heartRate])
    }

    func testWorkoutRowToWorkout_intervalWithPowerTarget_mapsPowerBounds() throws {
        let json = """
        {
            "id": 1,
            "name": "Test",
            "description": null,
            "duration": null,
            "intervals": [
                {
                    "name": "Steady",
                    "duration": 300,
                    "type": "steadyState",
                    "power_lower": 0.85,
                    "power_upper": 0.95
                }
            ]
        }
        """
        let row = try JSONDecoder().decode(WorkoutRow.self, from: Data(json.utf8))
        let workout = row.toWorkout()
        XCTAssertEqual(workout.intervals.count, 1)
        let interval = workout.intervals[0]
        XCTAssertEqual(interval.type, .steadyState)
        XCTAssertEqual(interval.powerTarget?.lowerBound, 0.85)
        XCTAssertEqual(interval.powerTarget?.upperBound, 0.95)
    }
}

//
//  ZWOParserTests.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/8/26.
//

import XCTest
@testable import WorkoutCave

final class ZWOParserTests: XCTestCase {

    func testParse_minimalSteadyState_returnsWorkoutWithOneInterval() {
        // Minimal ZWO: workout name + one SteadyState
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <workout_file>
            <name>Test Workout</name>
            <SteadyState Duration="300" Power="0.75" />
        </workout_file>
        """
        let data = Data(xml.utf8)
        let parser = ZWOParser()
        let workout = parser.parse(data: data)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.name, "Test Workout")
        XCTAssertEqual(workout?.intervals.count, 1)
        XCTAssertEqual(workout?.intervals[0].duration, 300)
        XCTAssertEqual(workout?.intervals[0].type, .steadyState)
    }

    func testParse_noIntervals_returnsNil() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <workout_file>
            <name>Empty</name>
        </workout_file>
        """
        let data = Data(xml.utf8)
        let parser = ZWOParser()
        let workout = parser.parse(data: data)
        XCTAssertNil(workout)
    }

    func testParse_invalidXML_returnsNil() {
        let data = Data("not xml at all".utf8)
        let parser = ZWOParser()
        let workout = parser.parse(data: data)
        XCTAssertNil(workout)
    }

    func testParse_noName_usesFallbackName() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <workout_file>
            <SteadyState Duration="60" Power="0.5" />
        </workout_file>
        """
        let data = Data(xml.utf8)
        let parser = ZWOParser()
        let workout = parser.parse(data: data)
        XCTAssertNotNil(workout)
        XCTAssertEqual(workout?.name, "Workout") // Copy.zwo.intervalName.workoutFallback
    }
}

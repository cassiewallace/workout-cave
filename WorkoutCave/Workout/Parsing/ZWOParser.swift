//
//  ZWOParser.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

final class ZWOParser: NSObject, XMLParserDelegate {

    // MARK: - Properties

    private var workoutName: String = ""
    private var intervals: [Workout.Interval] = []

    private var currentDuration: TimeInterval = 0
    private var currentName: String = ""
    private var currentMessages: [String] = []
    private var currentType: Workout.Interval.IntervalType = .steadyState

    // Interval state
    private var intervalsTOnDuration: TimeInterval = 0
    private var intervalsTOffDuration: TimeInterval = 0
    private var intervalsTRepeat: Int = 0
    private var currentPowerTarget: Workout.Interval.PowerTarget?

    // Track whether we're inside <workout_file>
    private var isParsingWorkoutFileName = false
    private var characterBuffer = ""

    // MARK: - Public API

    func parse(data: Data, id: String) -> Workout? {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse(), !intervals.isEmpty else {
            return nil
        }

        return Workout(
            id: id,
            name: workoutName.isEmpty ? "Workout" : workoutName,
            intervals: intervals
        )
    }

    // MARK: - XMLParserDelegate

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String : String]
    ) {

        switch elementName {

        case "name":
            characterBuffer = ""
            isParsingWorkoutFileName = true

        case "workout":
            // Older Zwift format fallback
            if workoutName.isEmpty {
                workoutName = attributeDict["name"] ?? ""
            }

        case "SteadyState":
            beginInterval(
                name: "Steady State",
                type: .steadyState,
                duration: attributeDict["Duration"]
            )

        case "Ramp":
            beginInterval(
                name: "Ramp",
                type: .steadyState,
                duration: attributeDict["Duration"]
            )

        case "Cooldown":
            beginInterval(
                name: "Cooldown",
                type: .cooldown,
                duration: attributeDict["Duration"]
            )

        case "FreeRide":
            beginInterval(
                name: "Free Ride",
                type: .freeRide,
                duration: attributeDict["Duration"]
            )

        case "IntervalsT":
            currentName = "Intervals"
            currentType = .intervalOn
            currentMessages = []

            intervalsTOnDuration = TimeInterval(attributeDict["OnDuration"] ?? "") ?? 0
            intervalsTOffDuration = TimeInterval(attributeDict["OffDuration"] ?? "") ?? 0
            intervalsTRepeat = Int(attributeDict["Repeat"] ?? "") ?? 0

        case let name where name.lowercased() == "textevent":
            if let message = attributeDict["message"] {
                currentMessages.append(message)
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isParsingWorkoutFileName else { return }
        characterBuffer += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {

        switch elementName {

        case "name":
            if isParsingWorkoutFileName && workoutName.isEmpty {
                workoutName = characterBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            isParsingWorkoutFileName = false

        case "SteadyState", "Ramp", "Cooldown", "FreeRide":
            appendInterval(
                duration: currentDuration,
                name: currentName,
                type: currentType
            )
            resetCurrentInterval()

        case "IntervalsT":
            for i in 1...intervalsTRepeat {
                appendInterval(
                    duration: intervalsTOnDuration,
                    name: "\(currentName) On \(i)",
                    type: .intervalOn
                )
                appendInterval(
                    duration: intervalsTOffDuration,
                    name: "\(currentName) Off \(i)",
                    type: .intervalOff
                )
            }
            resetIntervalsT()

        default:
            break
        }
    }

    // MARK: - Helpers

    private func beginInterval(
        name: String,
        type: Workout.Interval.IntervalType,
        duration: String?,
        powerLow: String? = nil,
        powerHigh: String? = nil,
        power: String? = nil
    ) {
        currentName = name
        currentType = type
        currentDuration = TimeInterval(duration ?? "") ?? 0
        currentMessages = []

        currentPowerTarget =
            powerTarget(
                low: powerLow ?? power,
                high: powerHigh ?? power
            )
    }

    private func appendInterval(
        duration: TimeInterval,
        name: String,
        type: Workout.Interval.IntervalType
    ) {
        guard duration > 0 else { return }

        intervals.append(
            Workout.Interval(
                duration: duration,
                name: name,
                message: currentMessages.isEmpty
                    ? nil
                    : currentMessages.joined(separator: "\n"),
                type: type
            )
        )
    }
    
    private func powerTarget(
        low: String?,
        high: String?
    ) -> Workout.Interval.PowerTarget? {
        let lowVal = low.flatMap(Double.init)
        let highVal = high.flatMap(Double.init)

        guard lowVal != nil || highVal != nil else { return nil }

        return Workout.Interval.PowerTarget(
            lowerBound: lowVal,
            upperBound: highVal ?? lowVal
        )
    }

    private func resetCurrentInterval() {
        currentDuration = 0
        currentName = ""
        currentMessages = []
        currentType = .steadyState
    }

    private func resetIntervalsT() {
        intervalsTOnDuration = 0
        intervalsTOffDuration = 0
        intervalsTRepeat = 0
        currentName = ""
        currentMessages = []
        currentType = .steadyState
    }
}

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
    private var currentPowerTarget: Workout.Interval.PowerTarget?

    private var intervalsTRepeat: Int = 0
    private var intervalsTOnDuration: TimeInterval = 0
    private var intervalsTOffDuration: TimeInterval = 0
    private var intervalsTOnPower: Workout.Interval.PowerTarget?
    private var intervalsTOffPower: Workout.Interval.PowerTarget?

    // workout_file <name> support
    private var isReadingWorkoutFileName: Bool = false
    private var nameBuffer: String = ""

    // MARK: - Public API

    func parse(data: Data) -> Workout? {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse(), !intervals.isEmpty else {
            return nil
        }

        return Workout(
            id: UUID().uuidString,
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
            // <workout_file><name>...</name></workout_file>
            // (Zwift uses this, not <workout name="...">)
            isReadingWorkoutFileName = true
            nameBuffer = ""

        case "SteadyState":
            beginInterval(
                name: "Steady State",
                type: .steadyState,
                duration: attributeDict["Duration"],
                powerLow: attributeDict["Power"],
                powerHigh: attributeDict["Power"]
            )

        case "Warmup":
            beginInterval(
                name: "Warmup",
                type: .warmup,
                duration: attributeDict["Duration"],
                powerLow: attributeDict["PowerLow"],
                powerHigh: attributeDict["PowerHigh"]
            )

        case "Cooldown":
            beginInterval(
                name: "Cooldown",
                type: .cooldown,
                duration: attributeDict["Duration"],
                powerLow: attributeDict["PowerLow"],
                powerHigh: attributeDict["PowerHigh"]
            )

        case "FreeRide":
            beginInterval(
                name: "Free Ride",
                type: .freeRide,
                duration: attributeDict["Duration"],
                powerLow: nil,
                powerHigh: nil
            )

        case "Ramp":
            beginInterval(
                name: "Ramp",
                type: .steadyState,
                duration: attributeDict["Duration"],
                powerLow: attributeDict["PowerLow"],
                powerHigh: attributeDict["PowerHigh"]
            )

        case "IntervalsT":
            currentName = "Intervals"
            currentMessages = []

            intervalsTRepeat = Int(attributeDict["Repeat"] ?? "") ?? 0
            intervalsTOnDuration = TimeInterval(attributeDict["OnDuration"] ?? "") ?? 0
            intervalsTOffDuration = TimeInterval(attributeDict["OffDuration"] ?? "") ?? 0

            intervalsTOnPower = powerTarget(
                low: attributeDict["OnPower"],
                high: attributeDict["OnPower"]
            )

            intervalsTOffPower = powerTarget(
                low: attributeDict["OffPower"],
                high: attributeDict["OffPower"]
            )

        case let name where name.lowercased() == "textevent":
            if let message = attributeDict["message"] {
                currentMessages.append(message)
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isReadingWorkoutFileName else { return }
        nameBuffer += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {

        switch elementName {

        case "name":
            isReadingWorkoutFileName = false
            let trimmed = nameBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                workoutName = trimmed
            }
            nameBuffer = ""

        case "SteadyState", "Warmup", "Cooldown", "FreeRide", "Ramp":
            appendCurrentInterval()
            resetCurrentInterval()

        case "IntervalsT":
            guard intervalsTRepeat > 0 else {
                resetIntervalsT()
                return
            }

            let message = joinedMessages

            for i in 1...intervalsTRepeat {
                intervals.append(
                    Workout.Interval(
                        duration: intervalsTOnDuration,
                        name: "\(currentName) On \(i)",
                        message: message,
                        type: .intervalOn,
                        powerTarget: intervalsTOnPower
                    )
                )

                intervals.append(
                    Workout.Interval(
                        duration: intervalsTOffDuration,
                        name: "\(currentName) Off \(i)",
                        message: message,
                        type: .intervalOff,
                        powerTarget: intervalsTOffPower
                    )
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
        powerLow: String?,
        powerHigh: String?
    ) {
        currentName = name
        currentType = type
        currentDuration = TimeInterval(duration ?? "") ?? 0
        currentMessages = []
        currentPowerTarget = powerTarget(low: powerLow, high: powerHigh)
    }

    private func appendCurrentInterval() {
        guard currentDuration > 0 else { return }

        intervals.append(
            Workout.Interval(
                duration: currentDuration,
                name: currentName,
                message: joinedMessages,
                type: currentType,
                powerTarget: currentPowerTarget
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

    private var joinedMessages: String? {
        currentMessages.isEmpty ? nil : currentMessages.joined(separator: "\n")
    }

    private func resetCurrentInterval() {
        currentDuration = 0
        currentName = ""
        currentMessages = []
        currentType = .steadyState
        currentPowerTarget = nil
    }

    private func resetIntervalsT() {
        intervalsTRepeat = 0
        intervalsTOnDuration = 0
        intervalsTOffDuration = 0
        intervalsTOnPower = nil
        intervalsTOffPower = nil
        currentName = ""
        currentMessages = []
    }
}

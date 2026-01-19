//
//  ZWOParser.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

final class ZWOParser: NSObject, XMLParserDelegate {

    // MARK: - Properties

    private var workoutName: String = Constants.Placeholder.empty
    private var workoutDescription: String = Constants.Placeholder.empty

    // Buffers for workout_file text nodes
    private var isReadingWorkoutName = false
    private var isReadingWorkoutDescription = false
    private var textBuffer: String = Constants.Placeholder.empty

    // MARK: - Interval state

    private var intervals: [Workout.Interval] = []

    private var currentDuration: TimeInterval = 0
    private var currentName: String = Constants.Placeholder.empty
    private var currentMessages: [String] = []
    private var currentType: Workout.Interval.IntervalType = .steadyState
    private var currentPowerTarget: Workout.Interval.PowerTarget?

    // IntervalsT state
    private var intervalsTRepeat: Int = 0
    private var intervalsTOnDuration: TimeInterval = 0
    private var intervalsTOffDuration: TimeInterval = 0
    private var intervalsTOnPower: Workout.Interval.PowerTarget?
    private var intervalsTOffPower: Workout.Interval.PowerTarget?

    // MARK: - Public API

    func parse(data: Data) -> Workout? {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse(), !intervals.isEmpty else {
            return nil
        }

        return Workout(
            id: UUID().uuidString,
            name: workoutName.isEmpty ? Constants.ZWO.IntervalName.workoutFallback : workoutName,
            description: workoutDescription,
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

        // ---- Workout-level metadata ----

        case Constants.ZWO.Element.name:
            isReadingWorkoutName = true
            textBuffer = Constants.Placeholder.empty

        case Constants.ZWO.Element.description:
            isReadingWorkoutDescription = true
            textBuffer = Constants.Placeholder.empty

        // ---- Intervals ----

        case Constants.ZWO.Element.steadyState:
            beginInterval(
                name: Constants.ZWO.IntervalName.steadyState,
                type: .steadyState,
                duration: attributeDict[Constants.ZWO.Attribute.duration],
                powerLow: attributeDict[Constants.ZWO.Attribute.power],
                powerHigh: attributeDict[Constants.ZWO.Attribute.power]
            )

        case Constants.ZWO.Element.warmup:
            beginInterval(
                name: Constants.ZWO.IntervalName.warmup,
                type: .warmup,
                duration: attributeDict[Constants.ZWO.Attribute.duration],
                powerLow: attributeDict[Constants.ZWO.Attribute.powerLow],
                powerHigh: attributeDict[Constants.ZWO.Attribute.powerHigh]
            )

        case Constants.ZWO.Element.cooldown:
            beginInterval(
                name: Constants.ZWO.IntervalName.cooldown,
                type: .cooldown,
                duration: attributeDict[Constants.ZWO.Attribute.duration],
                powerLow: attributeDict[Constants.ZWO.Attribute.powerLow],
                powerHigh: attributeDict[Constants.ZWO.Attribute.powerHigh]
            )

        case Constants.ZWO.Element.freeRide:
            beginInterval(
                name: Constants.ZWO.IntervalName.freeRide,
                type: .freeRide,
                duration: attributeDict[Constants.ZWO.Attribute.duration],
                powerLow: nil,
                powerHigh: nil
            )

        case Constants.ZWO.Element.ramp:
            beginInterval(
                name: Constants.ZWO.IntervalName.ramp,
                type: .steadyState,
                duration: attributeDict[Constants.ZWO.Attribute.duration],
                powerLow: attributeDict[Constants.ZWO.Attribute.powerLow],
                powerHigh: attributeDict[Constants.ZWO.Attribute.powerHigh]
            )

        case Constants.ZWO.Element.intervalsT:
            currentName = Constants.ZWO.IntervalName.intervals
            currentMessages = []

            intervalsTRepeat = Int(attributeDict[Constants.ZWO.Attribute.repeatCount] ?? Constants.Placeholder.empty) ?? 0
            intervalsTOnDuration = TimeInterval(attributeDict[Constants.ZWO.Attribute.onDuration] ?? Constants.Placeholder.empty) ?? 0
            intervalsTOffDuration = TimeInterval(attributeDict[Constants.ZWO.Attribute.offDuration] ?? Constants.Placeholder.empty) ?? 0

            intervalsTOnPower = powerTarget(
                low: attributeDict[Constants.ZWO.Attribute.onPower],
                high: attributeDict[Constants.ZWO.Attribute.onPower]
            )

            intervalsTOffPower = powerTarget(
                low: attributeDict[Constants.ZWO.Attribute.offPower],
                high: attributeDict[Constants.ZWO.Attribute.offPower]
            )

        case let name where name.lowercased() == Constants.ZWO.Element.textEventLowercased:
            if let message = attributeDict[Constants.ZWO.Attribute.message] {
                currentMessages.append(message)
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isReadingWorkoutName || isReadingWorkoutDescription {
            textBuffer += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {

        switch elementName {

        // ---- Workout-level metadata ----

        case Constants.ZWO.Element.name:
            isReadingWorkoutName = false
            let trimmed = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                workoutName = trimmed
            }
            textBuffer = Constants.Placeholder.empty

        case Constants.ZWO.Element.description:
            isReadingWorkoutDescription = false
            workoutDescription = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            textBuffer = Constants.Placeholder.empty

        // ---- Intervals ----

        case Constants.ZWO.Element.steadyState,
             Constants.ZWO.Element.warmup,
             Constants.ZWO.Element.cooldown,
             Constants.ZWO.Element.freeRide,
             Constants.ZWO.Element.ramp:
            appendCurrentInterval()
            resetCurrentInterval()

        case Constants.ZWO.Element.intervalsT:
            guard intervalsTRepeat > 0 else {
                resetIntervalsT()
                return
            }

            let message = joinedMessages

            for i in 1...intervalsTRepeat {
                intervals.append(
                    Workout.Interval(
                        duration: intervalsTOnDuration,
                        name: currentName
                        + Constants.Separator.space
                        + Constants.ZWO.IntervalToken.on
                        + Constants.Separator.space
                        + String(i),
                        message: message,
                        type: .intervalOn,
                        powerTarget: intervalsTOnPower
                    )
                )

                intervals.append(
                    Workout.Interval(
                        duration: intervalsTOffDuration,
                        name: currentName
                        + Constants.Separator.space
                        + Constants.ZWO.IntervalToken.off
                        + Constants.Separator.space
                        + String(i),
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
        currentDuration = TimeInterval(duration ?? Constants.Placeholder.empty) ?? 0
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
        currentMessages.isEmpty ? nil : currentMessages.joined(separator: Constants.Format.newline)
    }

    private func resetCurrentInterval() {
        currentDuration = 0
        currentName = Constants.Placeholder.empty
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
        currentName = Constants.Placeholder.empty
        currentMessages = []
    }
}

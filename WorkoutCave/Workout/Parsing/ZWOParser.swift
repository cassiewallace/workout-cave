//
//  ZWOParser.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

final class ZWOParser: NSObject, XMLParserDelegate {

    // MARK: - Properties

    private var workoutName: String = Copy.placeholder.empty
    private var workoutDescription: String?

    // Buffers for workout_file text nodes
    private var isReadingWorkoutName = false
    private var isReadingWorkoutDescription = false
    private var textBuffer: String = Copy.placeholder.empty

    // MARK: - Interval state

    private var intervals: [Workout.Interval] = []

    private var currentDuration: TimeInterval = 0
    private var currentName: String = Copy.placeholder.empty
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
            name: workoutName.isEmpty ? Copy.zwo.intervalName.workoutFallback : workoutName,
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

        case Copy.zwo.element.name:
            isReadingWorkoutName = true
            textBuffer = Copy.placeholder.empty

        case Copy.zwo.element.description:
            isReadingWorkoutDescription = true
            textBuffer = Copy.placeholder.empty

        // ---- Intervals ----

        case Copy.zwo.element.steadyState:
            beginInterval(
                name: Copy.zwo.intervalName.steadyState,
                type: .steadyState,
                duration: attributeDict[Copy.zwo.attribute.duration],
                powerLow: attributeDict[Copy.zwo.attribute.power],
                powerHigh: attributeDict[Copy.zwo.attribute.power]
            )

        case Copy.zwo.element.warmup:
            beginInterval(
                name: Copy.zwo.intervalName.warmup,
                type: .warmup,
                duration: attributeDict[Copy.zwo.attribute.duration],
                powerLow: attributeDict[Copy.zwo.attribute.powerLow],
                powerHigh: attributeDict[Copy.zwo.attribute.powerHigh]
            )

        case Copy.zwo.element.cooldown:
            beginInterval(
                name: Copy.zwo.intervalName.cooldown,
                type: .cooldown,
                duration: attributeDict[Copy.zwo.attribute.duration],
                powerLow: attributeDict[Copy.zwo.attribute.powerLow],
                powerHigh: attributeDict[Copy.zwo.attribute.powerHigh]
            )

        case Copy.zwo.element.freeRide:
            beginInterval(
                name: Copy.zwo.intervalName.freeRide,
                type: .freeRide,
                duration: attributeDict[Copy.zwo.attribute.duration],
                powerLow: nil,
                powerHigh: nil
            )

        case Copy.zwo.element.ramp:
            beginInterval(
                name: Copy.zwo.intervalName.ramp,
                type: .steadyState,
                duration: attributeDict[Copy.zwo.attribute.duration],
                powerLow: attributeDict[Copy.zwo.attribute.powerLow],
                powerHigh: attributeDict[Copy.zwo.attribute.powerHigh]
            )

        case Copy.zwo.element.intervalsT:
            currentName = Copy.zwo.intervalName.intervals
            currentMessages = []

            intervalsTRepeat = Int(attributeDict[Copy.zwo.attribute.repeatCount] ?? Copy.placeholder.empty) ?? 0
            intervalsTOnDuration = TimeInterval(attributeDict[Copy.zwo.attribute.onDuration] ?? Copy.placeholder.empty) ?? 0
            intervalsTOffDuration = TimeInterval(attributeDict[Copy.zwo.attribute.offDuration] ?? Copy.placeholder.empty) ?? 0

            intervalsTOnPower = powerTarget(
                low: attributeDict[Copy.zwo.attribute.onPower],
                high: attributeDict[Copy.zwo.attribute.onPower]
            )

            intervalsTOffPower = powerTarget(
                low: attributeDict[Copy.zwo.attribute.offPower],
                high: attributeDict[Copy.zwo.attribute.offPower]
            )

        case let name where name.lowercased() == Copy.zwo.element.textEventLowercased:
            if let message = attributeDict[Copy.zwo.attribute.message] {
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

        case Copy.zwo.element.name:
            isReadingWorkoutName = false
            let trimmed = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                workoutName = trimmed
            }
            textBuffer = Copy.placeholder.empty

        case Copy.zwo.element.description:
            isReadingWorkoutDescription = false
            let trimmed = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            workoutDescription = trimmed.isEmpty ? nil : trimmed
            textBuffer = Copy.placeholder.empty

        // ---- Intervals ----

        case Copy.zwo.element.steadyState,
             Copy.zwo.element.warmup,
             Copy.zwo.element.cooldown,
             Copy.zwo.element.freeRide,
             Copy.zwo.element.ramp:
            appendCurrentInterval()
            resetCurrentInterval()

        case Copy.zwo.element.intervalsT:
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
                        + Copy.separator.space
                        + Copy.zwo.intervalToken.on
                        + Copy.separator.space
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
                        + Copy.separator.space
                        + Copy.zwo.intervalToken.off
                        + Copy.separator.space
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
        currentDuration = TimeInterval(duration ?? Copy.placeholder.empty) ?? 0
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
        currentMessages.isEmpty ? nil : currentMessages.joined(separator: Copy.format.newline)
    }

    private func resetCurrentInterval() {
        currentDuration = 0
        currentName = Copy.placeholder.empty
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
        currentName = Copy.placeholder.empty
        currentMessages = []
    }
}

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
    private var currentMessage: String?

    // IntervalsT state
    private var intervalsTOnDuration: TimeInterval = 0
    private var intervalsTOffDuration: TimeInterval = 0
    private var intervalsTRepeat: Int = 0

    // MARK: - Public API

    func parse(data: Data) -> Workout? {
        let parser = XMLParser(data: data)
        parser.delegate = self

        guard parser.parse(), !intervals.isEmpty else {
            return nil
        }

        return Workout(
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
        attributes attributeDict: [String : String] = [:]
    ) {

        switch elementName {

        case "workout":
            workoutName = attributeDict["name"] ?? workoutName

        case "Warmup", "SteadyState", "Cooldown", "FreeRide":
            currentName = elementName
            currentDuration = TimeInterval(attributeDict["Duration"] ?? "") ?? 0
            currentMessage = nil

        case "IntervalsT":
            currentName = "Intervals"
            intervalsTOnDuration = TimeInterval(attributeDict["OnDuration"] ?? "") ?? 0
            intervalsTOffDuration = TimeInterval(attributeDict["OffDuration"] ?? "") ?? 0
            intervalsTRepeat = Int(attributeDict["Repeat"] ?? "") ?? 0
            currentMessage = nil

        case let name where name.lowercased() == "textevent":
            currentMessage = attributeDict["message"]

        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {

        switch elementName {

        case "Warmup", "SteadyState", "Cooldown", "FreeRide":
            if currentDuration > 0 {
                intervals.append(
                    Workout.Interval(
                        duration: currentDuration,
                        name: currentName,
                        message: currentMessage
                    )
                )
            }
            resetCurrentInterval()

        case "IntervalsT":
            if intervalsTRepeat > 0,
               intervalsTOnDuration > 0,
               intervalsTOffDuration > 0 {

                for i in 1...intervalsTRepeat {
                    intervals.append(
                        Workout.Interval(
                            duration: intervalsTOnDuration,
                            name: "\(currentName) On \(i)",
                            message: currentMessage
                        )
                    )
                    intervals.append(
                        Workout.Interval(
                            duration: intervalsTOffDuration,
                            name: "\(currentName) Off \(i)",
                            message: currentMessage
                        )
                    )
                }
            }
            resetIntervalsT()

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("ZWO parse error:", parseError.localizedDescription)
    }

    // MARK: - Helpers

    private func resetCurrentInterval() {
        currentDuration = 0
        currentName = ""
        currentMessage = nil
    }

    private func resetIntervalsT() {
        intervalsTOnDuration = 0
        intervalsTOffDuration = 0
        intervalsTRepeat = 0
        currentName = ""
        currentMessage = nil
    }
}

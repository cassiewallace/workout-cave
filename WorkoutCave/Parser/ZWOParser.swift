//
//  ZWOParser.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation

class ZWOParser: NSObject, XMLParserDelegate {
    // MARK: - Properties
    
    private var workoutName: String = ""
    private var intervals: [Workout.Interval] = []
    private var currentElement: String = ""
    private var currentDuration: TimeInterval = 0
    private var currentName: String = ""
    private var inWorkout: Bool = false
    private var inWorkoutFile: Bool = false
    
    // For IntervalsT
    private var intervalsTOnDuration: TimeInterval = 0
    private var intervalsTOffDuration: TimeInterval = 0
    private var intervalsTRepeat: Int = 0
    
    // MARK: - Public Methods
    
    func parse(data: Data) -> Workout? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        guard parser.parse() else {
            return nil
        }
        
        guard !intervals.isEmpty else {
            return nil
        }
        
        return Workout(
            name: workoutName.isEmpty ? "Workout" : workoutName,
            intervals: intervals
        )
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "workout_file" {
            inWorkoutFile = true
        } else if elementName == "workout" {
            inWorkout = true
            if let name = attributeDict["name"] {
                workoutName = name
            }
        } else if elementName == "Warmup" || elementName == "SteadyState" || elementName == "Cooldown" || elementName == "FreeRide" {
            // Reset current interval data
            currentDuration = 0
            currentName = elementName
            
            // Try to get duration from attributes
            if let durationStr = attributeDict["Duration"], let duration = TimeInterval(durationStr) {
                currentDuration = duration
            }
        } else if elementName == "IntervalsT" {
            // Handle IntervalsT which has OnDuration, OffDuration, and Repeat
            currentName = "IntervalsT"
            intervalsTOnDuration = 0
            intervalsTOffDuration = 0
            intervalsTRepeat = 0
            
            if let onDurationStr = attributeDict["OnDuration"], let onDuration = TimeInterval(onDurationStr) {
                intervalsTOnDuration = onDuration
            }
            if let offDurationStr = attributeDict["OffDuration"], let offDuration = TimeInterval(offDurationStr) {
                intervalsTOffDuration = offDuration
            }
            if let repeatStr = attributeDict["Repeat"], let repeatCount = Int(repeatStr) {
                intervalsTRepeat = repeatCount
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // For text content, we might find duration or other info
        // Most ZWO files have duration in attributes, but handle text if needed
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "workout_file" {
            inWorkoutFile = false
        } else if elementName == "workout" {
            inWorkout = false
        } else if elementName == "Warmup" || elementName == "SteadyState" || elementName == "Cooldown" || elementName == "FreeRide" {
            if currentDuration > 0 {
                intervals.append(Workout.Interval(
                    duration: currentDuration,
                    name: currentName
                ))
            }
            currentDuration = 0
            currentName = ""
        } else if elementName == "IntervalsT" {
            // Expand IntervalsT into multiple on/off intervals
            if intervalsTRepeat > 0 && intervalsTOnDuration > 0 && intervalsTOffDuration > 0 {
                for i in 1...intervalsTRepeat {
                    intervals.append(Workout.Interval(
                        duration: intervalsTOnDuration,
                        name: "\(currentName) On \(i)"
                    ))
                    intervals.append(Workout.Interval(
                        duration: intervalsTOffDuration,
                        name: "\(currentName) Off \(i)"
                    ))
                }
            }
            intervalsTOnDuration = 0
            intervalsTOffDuration = 0
            intervalsTRepeat = 0
            currentName = ""
        }
        
        currentElement = ""
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parse error: \(parseError.localizedDescription)")
    }
}


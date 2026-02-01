//
//  Copy.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import Foundation

enum Copy {
    enum placeholder {
        static let empty = ""
        static let missingValue = "—"
    }

    enum navigationTitle {
        static let workouts = "Workouts"
        static let settings = "Settings"
        static let justRide = "Just Ride"
    }

    enum tabBar {
        static let workouts = "Workouts"
        static let settings = "Settings"
    }

    enum metrics {
        static let powerZone = "Power Zone"
        static let power = "Power"
        static let cadence = "Cadence"
        static let speed = "Speed"
        static let heartRate = "Heart Rate"
        static let targetZone = "Target Zone"
        static let currentZone = "Current Zone"
    }

    enum settings {
        static let setFTP = "Set FTP"
        static let ftpPlaceholder = "FTP"
        static let save = "Save"
        static let powerZones = "Power Zones"
        static let setFTPToViewZones = "Set FTP to view zones."
        static let gridZone = "Zone"
        static let gridName = "Name"
        static let gridTarget = "Target"
        static let devicesSection = "Devices"
        static let ftpSection = "Functional Threshold Power (FTP)"
        static let connectBike = "Connect to a bike"
        static let bluetoothDialogPlaceholder = "Display bluetooth dialog"
    }

    enum workoutList {
        static let justRideDescription = "No workout, no time, just metrics."
    }

    enum workoutPlayback {
        static let loadingWorkout = "Loading workout…"
        static let errorLoadingWorkout = "Error loading workout"
        static let workoutComplete = "Workout Complete"
        static let stopRideDialogTitle = "Are you sure you want to end this ride?"
        static let stopRideDialogStop = "End ride"
        static let stopRideDialogCancel = "Cancel"
    }

    enum bluetooth {
        static let unknownDevice = "Unknown Bike"
        static let dialogSearching = "Searching..."
        static let dialogUnauthorized = "Bluetooth permission denied: enable in Settings"
        static let dialogPoweredOff = "Bluetooth is off"

        enum statusText {
            static let idle = "Idle"
            static let scanning = "Searching for bike"
            static let unauthorized = "Bluetooth permission denied"
            static let poweredOff = "Bluetooth is off"
            static let connecting = "Connecting"
            static let connected = "Connected"
        }

        enum ftmsUUIDString {
            static let service = "1826"
            static let indoorBikeData = "2AD2"
            static let machineStatus = "2ACC"
            static let controlPoint = "2AD9"
        }
    }

    enum accessibility {
        static let close = "Close"
    }

    enum powerZone {
        static let setFTP = "Set FTP"

        enum label {
            static let recovery = "Recovery"
            static let endurance = "Endurance"
            static let tempo = "Tempo"
            static let threshold = "Threshold"
            static let vo2Max = "VO₂ Max"
            static let anaerobic = "Anaerobic"
            static let neuromuscular = "Neuromuscular"
        }
    }

    enum errorMessage {
        static let couldNotParseZwiftWorkout = "Could not parse Zwift workout file."
    }

    enum units {
        static let wattsSuffix = " W"
        static let wattsPlusSuffix = "+ W"
        static let wattsRangeSeparator = "–"
    }

    enum format {
        static let timeMinutesSeconds = "%d:%02d"
        static let oneDecimal = "%.1f"
        static let zoneNumber = "Z%d"
        static let newline = "\n"
    }

    enum separator {
        static let space = " "
        static let hyphen = "-"
    }

    enum fileExtension {
        static let json = "json"
        static let zwo = "zwo"
    }

    enum workoutResource {
        static let steadyStateBase = "steady-state-base"
        static let recoverySpin = "recovery-spin"
        static let powerIntervals3030 = "30-30-power-intervals"
        static let tempoIntervals9060 = "90-60-tempo-intervals"
        static let progressiveWarmup = "progressive-warmup"
        static let enduranceBuild = "endurance-build"
        static let fortyTwenty = "40-20"
    }

    enum errorDomain {
        static let jsonWorkoutSource = "JSONWorkoutSource"
        static let zwiftWorkoutSource = "ZwiftWorkoutSource"
    }

    enum debugLog {
        static let jsonDecodeErrorPrefix = "❌ JSON decode error:"
    }

    enum zwo {
        enum element {
            static let name = "name"
            static let description = "description"
            static let steadyState = "SteadyState"
            static let warmup = "Warmup"
            static let cooldown = "Cooldown"
            static let freeRide = "FreeRide"
            static let ramp = "Ramp"
            static let intervalsT = "IntervalsT"
            static let textEventLowercased = "textevent"
        }

        enum attribute {
            static let duration = "Duration"
            static let power = "Power"
            static let powerLow = "PowerLow"
            static let powerHigh = "PowerHigh"
            static let repeatCount = "Repeat"
            static let onDuration = "OnDuration"
            static let offDuration = "OffDuration"
            static let onPower = "OnPower"
            static let offPower = "OffPower"
            static let message = "message"
        }

        enum intervalName {
            static let workoutFallback = "Workout"
            static let steadyState = "Steady State"
            static let warmup = "Warmup"
            static let cooldown = "Cooldown"
            static let freeRide = "Free Ride"
            static let ramp = "Ramp"
            static let intervals = "Intervals"
        }

        enum intervalToken {
            static let on = "On"
            static let off = "Off"
        }
    }
}


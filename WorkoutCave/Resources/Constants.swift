//
//  Constants.swift
//  WorkoutCave
//
//  Centralized app constants (strings, ids, keys).
//

import Foundation

enum Constants {
    // MARK: - Common UI

    enum Placeholder {
        static let empty = ""
        static let missingValue = "—"
    }

    enum Units {
        static let wattsSuffix = " W"
        static let wattsPlusSuffix = "+ W"
        static let wattsRangeSeparator = "–"
    }

    enum Format {
        static let timeMinutesSeconds = "%d:%02d"
        static let oneDecimal = "%.1f"
        static let zoneNumber = "Z%d"
        static let newline = "\n"
    }

    enum Separator {
        static let space = " "
        static let hyphen = "-"
    }

    // MARK: - Navigation + Tabs

    enum NavigationTitle {
        static let workouts = "Workouts"
        static let settings = "Settings"
        static let justRide = "Just Ride"
    }

    enum TabBar {
        static let workouts = "Workouts"
        static let settings = "Settings"
    }

    enum SFSymbol {
        static let bicycle = "bicycle"
        static let person = "person"
        static let warningTriangle = "exclamationmark.triangle"
        static let playFill = "play.fill"
        static let pauseFill = "pause.fill"
        static let forward = "forward"
        static let restart = "arrow.counterclockwise"
    }

    enum AssetImage {
        static let bluetooth = "bluetooth"
        static let bluetoothX = "bluetooth-x"
        static let bluetoothSlash = "bluetooth-slash"
        static let bluetoothConnected = "bluetooth-connected"
    }

    // MARK: - Metrics / Cards

    enum Metrics {
        static let powerZone = "Power Zone"
        static let power = "Power"
        static let cadence = "Cadence"
        static let speed = "Speed"
        static let heartRate = "Heart Rate"
        static let targetZone = "Target Zone"
        static let currentZone = "Current Zone"
    }

    // MARK: - Settings

    enum Settings {
        static let setFTP = "Set FTP"
        static let ftpPlaceholder = "FTP"
        static let save = "Save"
        static let powerZones = "Power Zones"
        static let setFTPToViewZones = "Set FTP to view zones."
        static let gridZone = "Zone"
        static let gridName = "Name"
        static let gridTarget = "Target"
    }

    // MARK: - Workout List / Playback

    enum WorkoutList {
        static let justRideDescription = "No workout, no time, just metrics."
    }

    enum WorkoutPlayback {
        static let loadingWorkout = "Loading workout…"
        static let errorLoadingWorkout = "Error loading workout"
        static let workoutComplete = "Workout Complete"
    }

    // MARK: - Bluetooth

    enum Bluetooth {
        enum FTMSUUIDString {
            static let service = "1826"
            static let indoorBikeData = "2AD2"
            static let machineStatus = "2ACC"
            static let controlPoint = "2AD9"
        }

        enum StatusText {
            static let idle = "Idle"
            static let scanning = "Searching for bike"
            static let unauthorized = "Bluetooth permission denied"
            static let poweredOff = "Bluetooth is off"
            static let connecting = "Connecting"
            static let connected = "Connected"
        }

        enum Debug {
            static let activationPrompt = "Prompt will happen here."
        }
    }

    // MARK: - Power zones

    enum PowerZone {
        static let setFTP = "Set FTP"

        enum Label {
            static let recovery = "Recovery"
            static let endurance = "Endurance"
            static let tempo = "Tempo"
            static let threshold = "Threshold"
            static let vo2Max = "VO₂ Max"
            static let anaerobic = "Anaerobic"
            static let neuromuscular = "Neuromuscular"
        }
    }

    // MARK: - Workout resources

    enum FileExtension {
        static let json = "json"
        static let zwo = "zwo"
    }

    enum WorkoutResource {
        static let steadyStateBase = "steady-state-base"
        static let recoverySpin = "recovery-spin"
        static let powerIntervals3030 = "30-30-power-intervals"
        static let tempoIntervals9060 = "90-60-tempo-intervals"
        static let progressiveWarmup = "progressive-warmup"
        static let enduranceBuild = "endurance-build"
        static let fortyTwenty = "40-20"
    }

    // MARK: - Errors

    enum ErrorDomain {
        static let jsonWorkoutSource = "JSONWorkoutSource"
        static let zwiftWorkoutSource = "ZwiftWorkoutSource"
    }

    enum ErrorMessage {
        static let couldNotParseZwiftWorkout = "Could not parse Zwift workout file."
    }

    enum DebugLog {
        static let jsonDecodeErrorPrefix = "❌ JSON decode error:"
    }

    // MARK: - ZWO parsing

    enum ZWO {
        enum Element {
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

        enum Attribute {
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

        enum IntervalName {
            static let workoutFallback = "Workout"
            static let steadyState = "Steady State"
            static let warmup = "Warmup"
            static let cooldown = "Cooldown"
            static let freeRide = "Free Ride"
            static let ramp = "Ramp"
            static let intervals = "Intervals"
        }

        enum IntervalToken {
            static let on = "On"
            static let off = "Off"
        }
    }
}


# Workout Cave

A personal MVP iPad app for playing structured bike trainer workouts from ZWO files.

## Features

- Plays limited bundled ZWO workout files
- Displays current interval name and countdown timer
- Start/Pause, Skip Interval, and Restart controls
- Timing that remains accurate when app is backgrounded
- iPad-optimized layout supporting Split View and Slide Over

## Requirements

- iPad running iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.0+

## Setup

1. Open `WorkoutCave.xcodeproj` in Xcode
2. Replace `WorkoutCave/sample.zwo` with your own ZWO file (or keep the sample)
3. Build and run on an iPad simulator or device

## ZWO File Format

The app supports ZWO files with the following interval types:
- `Warmup` - Warmup interval
- `SteadyState` - Steady state interval
- `IntervalsT` - Repeating intervals (expanded into On/Off pairs)
- `Cooldown` - Cooldown interval
- `FreeRide` - Free ride interval

Each interval must have a `Duration` attribute (in seconds). `IntervalsT` requires `OnDuration`, `OffDuration`, and `Repeat` attributes.

## Usage

1. Launch the app - it automatically loads `sample.zwo`
2. Tap "Start" to begin the workout
3. The current interval name and remaining time are displayed prominently
4. Use "Pause" to pause/resume, "Skip Interval" to move to the next interval, or "Restart" to start over
5. The workout automatically advances through intervals
6. Timing remains accurate even when the app is backgrounded or the screen is locked

## Project Structure

- `WorkoutCaveApp.swift` - App entry point
- `WorkoutPlaybackView.swift` - Main playback screen UI
- `WorkoutEngine.swift` - Workout state management and timing logic
- `ZWOParser.swift` - XML parser for ZWO files
- `Workout.swift` - Data models for workouts and intervals
- `sample.zwo` - Sample workout file (replace with your own)

## Notes

This is a personal MVP and is not designed for App Store distribution. It intentionally omits features like trainer control, Bluetooth/ANT+ support, workout creation, history, and analytics to focus on core playback functionality.

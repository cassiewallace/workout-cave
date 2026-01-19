# Workout Cave

Workout Cave is a personal iOS app for playing structured bike workouts with a clean, focused UI.

## Features

- Plays bundled workouts from **Zwift ZWO** and **native JSON** files
- Clean playback screen with interval name, cues, large timer, and progress
- Start / Pause / Skip / Restart controls
- Accurate wall-clock timing that survives backgrounding and screen lock
- Supports power targets and FTP-based power zones
- Live metrics via Bluetooth FTMS (speed, cadence, power; heart rate when available)
- “Just Ride” mode for metrics-only
- Target Zone and Current Zone shown during workouts
- User FTP stored locally using SwiftData
- Adaptive layout for iPhone and iPad (portrait, landscape, Split View)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open `WorkoutCave.xcodeproj` in Xcode
2. Build and run on a simulator or device
3. (Recommended) Set your FTP in **Settings** to enable power zones
4. Workouts are bundled in the app:
   - `.zwo` files for Zwift workouts
   - `.json` files for native workouts

## Bluetooth

Workout Cave can connect to indoor bikes that support the Bluetooth **Fitness Machine Service (FTMS)**.

- The app shows a Bluetooth status icon in the toolbar.
- Tap the icon to prompt for Bluetooth permission and connect.

Notes:
- Simulator won’t provide real FTMS data.
- FTMS support varies by device; some bikes may not provide every metric.

## Workouts

Bundled workouts live in `WorkoutCave/Workout/RawData/`:

- **JSON workouts**: decoded directly into the `Workout` model.
- **ZWO workouts**: parsed from Zwift `.zwo` XML.

## Project notes

- **Strings & constants**:
  - `WorkoutCave/Resources/Copy.swift` contains app copy and other non-spacing constants (formats, ids, parsing tokens, etc.).
  - `WorkoutCave/Resources/Constants.swift` contains the spacing scale (`xxs`…`xxl`).

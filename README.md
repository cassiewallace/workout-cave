# Workout Cave

Workout Cave is a personal iOS app for playing structured bike workouts with a clean, focused UI.

## Features

- Plays bundled workouts from **Zwift ZWO** and **native JSON** files
- Clean playback screen with interval name, cues, large timer, and progress
- Start / Pause / Skip / Restart controls
- Accurate wall-clock timing that survives backgrounding and screen lock
- Supports power targets and FTP-based power zones
- User FTP stored locally using SwiftData
- Adaptive layout for iPhone and iPad (portrait, landscape, Split View)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open `WorkoutCave.xcodeproj` in Xcode
2. Build and run on a simulator or device
3. Workouts are bundled in the app:
   - `.zwo` files for Zwift workouts
   - `.json` files for native workouts

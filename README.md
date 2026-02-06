# Workout Cave

Workout Cave is a personal iOS app for playing structured bike workouts with a clean, focused UI.

## Features

- **Workouts**: "Just Ride" (metrics-only) plus structured workouts from Supabase
- Clean playback screen with interval name, cues, large timer, and progress
- Start / Pause / Skip controls (skip hidden for Just Ride)
- Accurate wall-clock timing that survives backgrounding and screen lock
- Supports power targets and FTP-based power zones
- Live metrics via Bluetooth FTMS (speed, cadence, power; heart rate when available)
- Target Zone and Current Zone shown during structured workouts
- Workout summary on completion (Average Power, Heart Rate)
- **Settings**: Training Zones (FTP & power zones), Appearance (light/dark/system), Units (mph/kph), Terms & Conditions
- User preferences stored locally using SwiftData
- Dark mode support
- Adaptive layout for iPhone and iPad (portrait, landscape, Split View)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup

1. Open `WorkoutCave.xcodeproj` in Xcode
2. Build and run on a simulator or device
3. (Recommended) Set your FTP in **Settings → Training Zones → Functional Threshold Power (FTP)** to enable power zones
4. Configure Supabase keys in `Info.plist`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY` (publishable/anon key)
5. Workouts are loaded from:
   - **Just Ride** (built-in, always first in the list)
   - **Supabase** (workouts + intervals)

## Bluetooth

Workout Cave can connect to indoor bikes that support the Bluetooth **Fitness Machine Service (FTMS)**.

- The app shows a Bluetooth status icon in the toolbar.
- Tap the icon to prompt for Bluetooth permission and connect.
- Bluetooth is managed by a **single shared** `BluetoothManager` across the app, so connection state and metrics are consistent between screens.

Notes:
- Simulator won’t provide real FTMS data.
- FTMS support varies by device; some bikes may not provide every metric.

## Workouts

Workout Cave loads workouts from:

- **Just Ride** — built-in metrics-only mode
- **Supabase** — fetches `workouts` and related `intervals` via the publishable/anon key (RLS controls access)

Zwift ZWO parsing is retained for future user-uploaded workouts.

## Supabase

Supabase is used as a lightweight backend to store workouts and intervals. The app reads from the `workouts` table with a related `intervals` relationship.

- Client uses the **publishable/anon key** from `Info.plist`.
- The **service_role/secret key is never used in the app**.
- RLS should allow read access for the anon role.

## Project structure

- **Strings & constants**:
  - `WorkoutCave/Resources/Copy.swift` — app copy, formats, ids, parsing tokens
  - `WorkoutCave/Resources/Constants.swift` — spacing scale (`xxs`…`xxl`)

## Privacy

See [PRIVACY.md](PRIVACY.md) for the privacy policy.

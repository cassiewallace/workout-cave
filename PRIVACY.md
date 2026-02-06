# Privacy Policy — Workout Cave

**Last updated:** February 2, 2026

Workout Cave ("the app") is committed to protecting your privacy. This policy explains what data the app uses and how it is handled.

## Data the app does not collect

- **Workout data**: The app does not collect, store, or transmit any of your workout sessions (duration, power, heart rate, etc.) to external servers.
- **Personal information**: The app does not require an account or collect personal information such as your name, email, or location.

## Data stored on your device

The app stores the following data **only on your device**:

- **FTP (Functional Threshold Power)** — used to calculate power zones and target ranges during workouts.
- **Units preference** — mph or kph for speed display.
- **Appearance preference** — light, dark, or system for the app’s color scheme.
- **Onboarding status** — whether you have seen the intro screen.
- **Bluetooth connection state** — which bike (if any) is connected.

This data is stored locally using Apple’s standard storage APIs and is never sent to external servers.

## Bluetooth

The app uses Bluetooth to connect to indoor bikes that support the Fitness Machine Service (FTMS). Bluetooth is used only to receive live metrics (power, cadence, speed, heart rate) for display during your ride. This data is displayed in real time and is not recorded or transmitted elsewhere.

## Network usage

The app connects to Supabase to **fetch** workout definitions (names, descriptions, interval structures). This is read-only: the app downloads workout content to display in the workout list. No data about you or your usage is sent to Supabase.

## Changes to this policy

We may update this privacy policy from time to time. The "Last updated" date at the top reflects the most recent revision. Your continued use of the app after changes constitutes acceptance of the updated policy.

## Contact

For questions about this privacy policy, open an issue in the [Workout Cave repository](https://github.com/cassiewallace/workout-cave).

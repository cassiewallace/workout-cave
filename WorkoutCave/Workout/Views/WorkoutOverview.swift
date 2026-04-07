//  WorkoutOverview.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 4/6/26.
//

import SwiftUI

struct WorkoutOverview: View {
    // MARK: - Properties

    let workout: Workout
    let onStart: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.xl) {
                if let description = workout.description {
                    Text(description)
                        .font(.title3)
                        .foregroundStyle(.primary)
                }

                durationSection

                if workout.hasIntervals {
                    intervalListSection
                }
            }
            .padding(.horizontal, Constants.l)
            .padding(.top, Constants.l)
            .padding(.bottom, Constants.xxxl)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onStart) {
                Text(Copy.workoutPlayback.startWorkout)
                    .padding(.vertical, Constants.s)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Constants.l)
            .padding(.vertical, Constants.m)
            .modifier(StartButtonStyle())
        }
    }

    // MARK: - Sections

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: Constants.xxs) {
            Text(Copy.workoutPlayback.totalDuration)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            Text(formattedDuration(workout.totalDuration))
                .font(.title2)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }

    private var intervalListSection: some View {
        VStack(alignment: .leading, spacing: Constants.s) {
            Text(Copy.workoutPlayback.intervals)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            VStack(spacing: 0) {
                ForEach(Array(workout.intervals.enumerated()), id: \.element.id) { index, interval in
                    OverviewIntervalRow(interval: interval)

                    if index < workout.intervals.count - 1 {
                        Divider()
                            .padding(.leading, Constants.l + Constants.xs + Constants.s)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Constants.m))
        }
    }

    // MARK: - Helpers

    private func formattedDuration(_ time: TimeInterval) -> String {
        let t = max(0, Int(time.rounded(.down)))
        let hours = t / 3600
        let minutes = (t % 3600) / 60
        let seconds = t % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: Copy.format.timeMinutesSeconds, minutes, seconds)
        }
    }
}

// MARK: - Interval Row

private struct OverviewIntervalRow: View {
    let interval: Workout.Interval

    var body: some View {
        HStack(alignment: .top, spacing: Constants.s) {
            RoundedRectangle(cornerRadius: Constants.xxxs)
                .fill(interval.type.color)
                .frame(width: Constants.xs, height: Constants.xl)
                .padding(.top, Constants.xxs)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Constants.xxxs) {
                Text(interval.name)
                    .font(.body)

                if let powerLabel = interval.powerTargetLabel {
                    Text(powerLabel)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(formattedDuration(interval.duration))
                .font(.body)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Constants.m)
        .padding(.vertical, Constants.s)
        .accessibilityElement(children: .combine)
    }

    private func formattedDuration(_ time: TimeInterval) -> String {
        let t = max(0, Int(time.rounded(.down)))
        let hours = t / 3600
        let minutes = (t % 3600) / 60
        let seconds = t % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: Copy.format.timeMinutesSeconds, minutes, seconds)
        }
    }
}

// MARK: - Interval.IntervalType + Color

private extension Workout.Interval.IntervalType {
    var color: Color {
        switch self {
        case .warmup:       return .blue
        case .steadyState:  return .green
        case .intervalOn:   return .red
        case .intervalOff:  return .mint
        case .recovery:     return .teal
        case .cooldown:     return .indigo
        case .freeRide:     return .purple
        }
    }
}

// MARK: - Workout.Interval + Power Label

private extension Workout.Interval {
    var powerTargetLabel: String? {
        guard let target = powerTarget else { return nil }

        let lower = target.lowerBound.map { Int(($0 * 100).rounded()) }
        let upper = target.upperBound.map { Int(($0 * 100).rounded()) }

        switch (lower, upper) {
        case let (lo?, up?) where lo == up:
            return "\(lo)\(Copy.workoutOverview.ftpSuffix)"
        case let (lo?, up?):
            return "\(lo)\(Copy.units.wattsRangeSeparator)\(up)\(Copy.workoutOverview.ftpSuffix)"
        case let (lo?, nil):
            return "\(lo)\(Copy.workoutOverview.ftpSuffix)"
        case let (nil, up?):
            return "\(up)\(Copy.workoutOverview.ftpSuffix)"
        case (nil, nil):
            return nil
        }
    }
}

// MARK: - Start Button Style

private struct StartButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .buttonStyle(.glassProminent)
        } else {
            content
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Preview

#Preview {
    let zwo = """
    <workout_file>
        <name>Sweet Spot Builder</name>
        <description>Build your aerobic base with sustained efforts at threshold.</description>
        <workout>
            <SteadyState Duration="600" Power="0.5" pace="0">
                <textevent timeoffset="0" message="Easy warmup."/>
            </SteadyState>
            <SteadyState Duration="1200" Power="0.88" pace="0">
                <textevent timeoffset="0" message="Sweet spot effort."/>
            </SteadyState>
            <IntervalsT Repeat="3" OnDuration="300" OffDuration="180" OnPower="0.95" OffPower="0.5" pace="0"/>
            <SteadyState Duration="420" Power="0.55" pace="0">
                <textevent timeoffset="0" message="Cool down."/>
            </SteadyState>
        </workout>
    </workout_file>
    """
    let data = Data(zwo.utf8)
    let source = ZwiftWorkoutSource(id: "preview", data: data)
    let workout = try! source.loadWorkout()

    NavigationStack {
        WorkoutOverview(workout: workout) { }
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

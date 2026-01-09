//  WorkoutPlayback.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

struct WorkoutPlayback: View {
    // MARK: - Properties

    @StateObject private var engine = WorkoutEngine()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let workoutSource: WorkoutSource

    // MARK: - Layout

    private var isCompactVertical: Bool {
        verticalSizeClass == .compact
    }

    private var sectionSpacing: CGFloat {
        isCompactVertical ? 16 : 40
    }

    private var innerSpacing: CGFloat {
        isCompactVertical ? 6 : 12
    }

    private var horizontalPadding: CGFloat {
        isCompactVertical ? 16 : 32
    }

    private var timerFontSize: CGFloat {
        isCompactVertical ? 64 : 128
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let workout = engine.workout {
                playbackContent(workout: workout)
            } else if let error = engine.errorMessage {
                errorView(error: error)
            } else {
                loadingView
            }
        }
        .task {
            engine.load(source: workoutSource)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background && newPhase == .active {
                engine.updateForForeground()
            }
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading workout…")
                .font(.headline)
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error loading workout")
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(horizontalPadding)
    }

    // MARK: - Playback

    private func playbackContent(workout: Workout) -> some View {
        VStack(spacing: sectionSpacing) {
            ProgressView(value: engine.intervalProgress)
                .foregroundStyle(.primary)
            intervalContent
            timerView
        }
        .padding(.top, sectionSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toolbar {
            controls
        }
    }

    // MARK: - Subviews
    
    private func workoutName(for workout: Workout) -> some View {
        Text(workout.name)
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }

    @ViewBuilder
    private var intervalContent: some View {
        if engine.playbackState == .finished {
            Text("Workout Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .multilineTextAlignment(.center)
        } else if let interval = engine.currentInterval {
            VStack(spacing: innerSpacing) {
                Text(interval.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if let label = interval.powerTarget?.zones().zoneLabel {
                    Text(label)
                }

                if let message = interval.message {
                    Text(message)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    @ViewBuilder
    private var timerView: some View {
        if engine.playbackState != .finished {
            Text(formatTime(engine.remainingTimeInInterval))
                .font(.system(size: timerFontSize, weight: .bold))
                // Compensate for system font descender space at large sizes
                .padding(.bottom, isCompactVertical ? -24 : 0)
                .monospacedDigit()
                .dynamicTypeSize(.large)
                .animation(.easeInOut(duration: 0.2), value: engine.remainingTimeInInterval)
        }
    }
    
    @ToolbarContentBuilder
    private var controls: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Control(
                controlType: .skip,
                action: engine.skipInterval,
                isDisabled: engine.playbackState == .idle || engine.playbackState == .finished
            )
        }

        if engine.playbackState == .running {
            ToolbarItem(placement: .bottomBar) {
                Control(
                    controlType: .pause,
                    action: engine.pause,
                    isDisabled: engine.playbackState == .finished
                )
            }
        } else if engine.playbackState == .paused || engine.playbackState == .idle {
            ToolbarItem(placement: .bottomBar) {
                Control(
                    controlType: .play,
                    action: engine.start,
                    isDisabled: engine.playbackState == .finished
                )
            }
        }

        ToolbarItem(placement: .bottomBar) {
            Control(
                controlType: .restart,
                action: engine.restart,
                isDisabled: engine.playbackState == .idle
            )
        }
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Portrait", traits: .portrait) {
    let url = Bundle.main.url(forResource: "40-20", withExtension: "zwo")!
    let data = try! Data(contentsOf: url)

    WorkoutPlayback(
        workoutSource: ZwiftWorkoutSource(
            id: "jen-intervals",
            data: data
        )
    )
}

#Preview("Landscape", traits: .landscapeLeft) {
    let url = Bundle.main.url(forResource: "40-20", withExtension: "zwo")!
    let data = try! Data(contentsOf: url)

    WorkoutPlayback(
        workoutSource: ZwiftWorkoutSource(
            id: "jen-intervals",
            data: data
        )
    )
}

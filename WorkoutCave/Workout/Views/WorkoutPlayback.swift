//  WorkoutPlayback.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftData
import SwiftUI

struct WorkoutPlayback: View {
    // MARK: - Properties

    @StateObject private var engine = WorkoutEngine()
    @StateObject private var bluetooth = BluetoothManager()
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // UserSettings
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

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
        .navigationTitle(engine.workout?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            controls
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
            intervalContent
            timerView
            ProgressView(value: engine.intervalProgress)
                .foregroundStyle(.primary)
        }
        .padding(.top, sectionSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .bluetoothStatus(using: bluetooth)
    }

    // MARK: - Subviews

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

                if let message = interval.message {
                    Text(message)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(4)
                }
                
                Spacer()
                
                if let label = interval.powerTarget?.zones().zoneLabel {
                    HStack {
                        MetricCard(name: "Target Zone", value: label)
                            .frame(maxWidth: 160)
                            .padding(6)
                        MetricCard(
                            name: "Current Zone",
                            value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts)
                        )
                            .frame(maxWidth: 160)
                            .padding(6)
                    }
                }
                Spacer()
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
        if engine.workout != nil {
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

    NavigationStack {
        WorkoutPlayback(
            workoutSource: ZwiftWorkoutSource(
                id: "jen-intervals",
                data: data
            )
        )
    }
}

#Preview("Landscape", traits: .landscapeLeft) {
    let url = Bundle.main.url(forResource: "40-20", withExtension: "zwo")!
    let data = try! Data(contentsOf: url)

    NavigationStack {
        WorkoutPlayback(
            workoutSource: ZwiftWorkoutSource(
                id: "jen-intervals",
                data: data
            )
        )
    }
}

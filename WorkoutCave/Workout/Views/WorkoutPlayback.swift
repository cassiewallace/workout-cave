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
        .navigationTitle(engine.workout?.name ?? Constants.Placeholder.empty)
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
        .bluetoothStatus(using: bluetooth)
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(Constants.WorkoutPlayback.loadingWorkout)
                .font(.headline)
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: Constants.SFSymbol.warningTriangle)
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(Constants.WorkoutPlayback.errorLoadingWorkout)
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
        ZStack(alignment: .topLeading) {
            if isCompactVertical {
                VStack(spacing: sectionSpacing) {
                    intervalContent
                    timer
                    Spacer()
                    ProgressView(value: engine.intervalProgress)
                        .foregroundStyle(.primary)
                        .padding(.bottom, 8)
                }
                .padding(.top, sectionSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                if let interval = engine.currentInterval {
                    metrics(for: interval)
                }
            } else {
                VStack(spacing: sectionSpacing) {
                    intervalContent
                    if let interval = engine.currentInterval {
                        metrics(for: interval)
                        Spacer()
                    }
                    timer
                    Spacer()
                    ProgressView(value: engine.intervalProgress)
                        .foregroundStyle(.primary)
                        .padding(.bottom, 8)
                }
                .padding(.top, sectionSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var intervalContent: some View {
        if engine.playbackState == .finished {
            Text(Constants.WorkoutPlayback.workoutComplete)
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
                        .padding(12)
                }
            }
        }
    }

    @ViewBuilder
    private var timer: some View {
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
    
    @ViewBuilder
    private func metrics(for interval: Workout.Interval) -> some View {
        if isCompactVertical {
            VStack(spacing: 6) {
                metricCards(for: interval)
            }
        } else {
            HStack(spacing: 6) {
                metricCards(for: interval)
            }
        }
    }
    
    @ViewBuilder
    private func metricCards(for interval: Workout.Interval) -> some View {
        if let label = interval.powerTarget?.zones().zoneLabel {
            MetricCard(name: Constants.Metrics.targetZone,
                       value: label,
                       fontSize: isCompactVertical ? 12 : 18,
                       maxHeight: isCompactVertical ? 80 : 120,
                       maxWidth: isCompactVertical ? 100 : 160)
            MetricCard(
                name: Constants.Metrics.currentZone,
                value: PowerZone.zoneNameLabel(for: bluetooth.metrics.powerWatts, ftp: userSettings?.ftpWatts),
                fontSize: isCompactVertical ? 12 : 18,
                maxHeight: isCompactVertical ? 80 : 120,
                maxWidth: isCompactVertical ? 100 : 160
            )
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
        return String(format: Constants.Format.timeMinutesSeconds, minutes, seconds)
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

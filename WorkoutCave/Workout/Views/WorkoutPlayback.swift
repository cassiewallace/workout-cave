//  WorkoutPlayback.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation
import SwiftData
import SwiftUI

struct WorkoutPlayback: View {
    // MARK: - Properties

    @StateObject private var engine = WorkoutEngine()
    @EnvironmentObject private var bluetooth: BluetoothManager
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // UserSettings
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    let workoutSource: WorkoutSource
    
    // MARK: - Power averaging (excluding 0 W)
    
    @State private var avgWattSeconds: Double = 0
    @State private var avgValidSeconds: Double = 0
    @State private var avgLastSampleDate: Date?
    @State private var avgSampleTimer: Timer?
    
    // MARK: - Just Ride stop
    
    @State private var isStopConfirmationPresented: Bool = false

    // MARK: - Layout
    
    @ScaledMetric(relativeTo: .title3) private var intervalMessageHeightRegular: CGFloat = 64
    @ScaledMetric(relativeTo: .title3) private var intervalMessageHeightCompact: CGFloat = 48

    private var isCompactVertical: Bool {
        verticalSizeClass == .compact
    }

    private var sectionSpacing: CGFloat {
        isCompactVertical ? Constants.l : (Constants.xl)
    }

    private var innerSpacing: CGFloat {
        isCompactVertical ? Constants.xs : Constants.m
    }

    private var horizontalPadding: CGFloat {
        isCompactVertical ? Constants.l : Constants.xxl
    }

    private var timerFontSize: CGFloat {
        isCompactVertical ? 56 : 112
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
        .navigationTitle(engine.workout?.name ?? Copy.placeholder.empty)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            Controls(
                engine: engine,
                isJustRide: engine.isJustRide,
                onStopTap: { isStopConfirmationPresented = true },
                onRestart: restart
            )
        }
        .task {
            engine.load(source: workoutSource)
            resetAveragePower()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background && newPhase == .active {
                engine.updateForForeground()
            }
        }
        .onChange(of: engine.playbackState) { oldState, newState in
            handlePlaybackStateChange(oldState: oldState, newState: newState)
        }
        .confirmationDialog(
            "End ride?",
            isPresented: $isStopConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Stop", role: .destructive) {
                stopRide()
            }
            Button("Cancel", role: .cancel) {}
        }
        .bluetoothStatus(using: bluetooth)
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: Constants.m) {
            ProgressView()
            Text(Copy.workoutPlayback.loadingWorkout)
                .font(.headline)
        }
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: Constants.l + Constants.xxs) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(Copy.workoutPlayback.errorLoadingWorkout)
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
                    progressBar
                }
                .padding(.top, sectionSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                if engine.playbackState != .finished { compactMetricsOverlay
                }
            } else {
                VStack(spacing: sectionSpacing) {
                    intervalContent
                    if engine.playbackState != .finished {
                        workoutMetricsBlock
                    }
                    timer
                    progressBar
                }
                .padding(.top, sectionSpacing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var progressBar: some View {
        Spacer()
        ProgressView(value: engine.intervalProgress)
            .foregroundStyle(.primary)
            .padding(.bottom, Constants.s)
        Spacer()
    }

    @ViewBuilder
    private var intervalContent: some View {
        if engine.playbackState == .finished {
            VStack(spacing: innerSpacing) {
                Text(Copy.workoutPlayback.workoutComplete)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
                Text("Average Power: \(averagePowerLabel)")
                    .font(.title3)
                    .monospacedDigit()
            }
        } else if engine.isJustRide {
            EmptyView()
        } else if let interval = engine.currentInterval {
            VStack(spacing: innerSpacing) {
                Text(interval.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                intervalMessage(message: interval.message)
            }
        }
    }

    private func intervalMessage(message: String?) -> some View {
        Text(message ?? Copy.placeholder.empty)
            .font(.title3)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.6)
            .allowsTightening(true)
            .truncationMode(.tail)
            .frame(
                maxWidth: .infinity,
                minHeight: isCompactVertical ? intervalMessageHeightCompact : intervalMessageHeightRegular,
                maxHeight: isCompactVertical ? intervalMessageHeightCompact : intervalMessageHeightRegular,
                alignment: .top
            )
            .padding(.horizontal, Constants.m)
    }

    @ViewBuilder
    private var timer: some View {
        if engine.playbackState != .finished {
            Text(formatElapsedTime(engine.isJustRide ? engine.elapsedTimeInInterval : engine.remainingTimeInInterval))
                .font(.system(size: timerFontSize, weight: .bold))
                // Compensate for system font descender space at large sizes
                .padding(.bottom, isCompactVertical ? -Constants.xl : Constants.none)
                .monospacedDigit()
                .dynamicTypeSize(.large)
                .animation(.easeInOut(duration: 0.2), value: engine.isJustRide ? engine.elapsedTimeInInterval : engine.remainingTimeInInterval)
        }
    }
    
    private var workoutMetricsBlock: some View {
        VStack(spacing: Constants.m) {
            LiveMetricsGrid(
                targetZoneLabel: engine.currentInterval?.powerTarget?.zones().zoneLabel,
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.targetZone, .zone, .power, .cadence, .speed, .heartRate]
            )
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var compactMetricsOverlay: some View {
        VStack(spacing: Constants.xs) {
            LiveMetricsGrid(
                targetZoneLabel: engine.currentInterval?.powerTarget?.zones().zoneLabel,
                zoneTitle: Copy.metrics.currentZone,
                metrics: [.zone, .heartRate],
                columnsPerRow: 1,
                fontSize: 12,
                maxHeight: 64,
                maxWidth: 96
            )
        }
    }

    // MARK: - Helpers

    private func formatElapsedTime(_ time: TimeInterval) -> String {
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
    
    private var averagePowerLabel: String {
        guard avgValidSeconds > 0 else { return Copy.placeholder.missingValue }
        let avg = (avgWattSeconds / avgValidSeconds).rounded()
        return "\(Int(avg)) W"
    }
    
    private func handlePlaybackStateChange(oldState: PlaybackState, newState: PlaybackState) {
        switch (oldState, newState) {
        case (_, .running):
            if oldState == .idle {
                resetAveragePower()
            }
            startAverageTimer()
        case (_, .paused), (_, .idle):
            stopAverageTimer()
        case (_, .finished):
            stopAverageTimer()
        }
    }
    
    private func startAverageTimer() {
        guard avgSampleTimer == nil else { return }
        avgLastSampleDate = Date()
        avgSampleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordAverageSample()
        }
    }
    
    private func stopAverageTimer() {
        avgSampleTimer?.invalidate()
        avgSampleTimer = nil
        avgLastSampleDate = nil
    }
    
    private func recordAverageSample() {
        guard engine.playbackState == .running else { return }
        
        let now = Date()
        guard let last = avgLastSampleDate else {
            avgLastSampleDate = now
            return
        }
        
        var dt = now.timeIntervalSince(last)
        if dt <= 0 {
            avgLastSampleDate = now
            return
        }
        
        dt = min(dt, 2.0)
        
        if let watts = bluetooth.metrics.powerWatts, watts > 0 {
            avgWattSeconds += Double(watts) * dt
            avgValidSeconds += dt
        }
        
        avgLastSampleDate = now
    }
    
    private func resetAveragePower() {
        stopAverageTimer()
        avgWattSeconds = 0
        avgValidSeconds = 0
    }
    
    private func restart() {
        engine.restart()
        resetAveragePower()
    }
    
    private func stopRide() {
        engine.finishNow()
    }
}

#Preview("Portrait", traits: .portrait) {
    WorkoutPlaybackPreviewHost()
}

#Preview("Landscape", traits: .landscapeLeft) {
    WorkoutPlaybackPreviewHost()
}

#Preview("Just Ride", traits: .portrait) {
    WorkoutPlaybackJustRidePreviewHost()
}

private struct WorkoutPlaybackPreviewHost: View {
    @StateObject private var bluetooth = BluetoothManager()

    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()

    private let workoutSource: WorkoutSource = {
        let url = Bundle.main.url(forResource: "40-20", withExtension: "zwo")!
        let data = try! Data(contentsOf: url)
        return ZwiftWorkoutSource(id: "jen-intervals", data: data)
    }()

    var body: some View {
        NavigationStack {
            WorkoutPlayback(workoutSource: workoutSource)
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
    }
}

private struct WorkoutPlaybackJustRidePreviewHost: View {
    @StateObject private var bluetooth = BluetoothManager()

    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        context.insert(UserSettings(id: "me", ftpWatts: 250))
        try? context.save()
        return c
    }()

    var body: some View {
        NavigationStack {
            WorkoutPlayback(workoutSource: JustRideWorkoutSource())
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
    }
}

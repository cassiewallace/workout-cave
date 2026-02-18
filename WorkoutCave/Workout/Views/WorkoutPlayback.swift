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
    
    // MARK: ViewState
    
    private enum ViewState {
        case loading
        case loaded(Workout)
        case error(String)
    }
    
    private var viewState: ViewState {
        if let workout = engine.workout {
            return .loaded(workout)
        } else if let error = engine.errorMessage {
            return .error(error)
        } else {
            return .loading
        }
    }

    @StateObject private var engine: WorkoutEngine
    @EnvironmentObject private var bluetooth: BluetoothManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // UserSettings
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<UserSettings> { $0.id == "me" })
    private var settings: [UserSettings]
    private var userSettings: UserSettings? { settings.first }

    let workoutSource: WorkoutSource
    private let autoLoad: Bool
    private let previewMaxHeartRate: Int?  // Optional override for previews

    @MainActor
    init(workoutSource: WorkoutSource, autoLoad: Bool = true, previewMaxHeartRate: Int? = nil) {
        self.workoutSource = workoutSource
        self.autoLoad = autoLoad
        self.previewMaxHeartRate = previewMaxHeartRate
        _engine = StateObject(wrappedValue: WorkoutEngine())
    }

    init(workoutSource: WorkoutSource, autoLoad: Bool, engine: WorkoutEngine, previewMaxHeartRate: Int? = nil) {
        self.workoutSource = workoutSource
        self.autoLoad = autoLoad
        self.previewMaxHeartRate = previewMaxHeartRate
        _engine = StateObject(wrappedValue: engine)
    }
    
    // MARK: - Just Ride stop
    
    @State private var isStopConfirmationPresented: Bool = false
    @State private var stopConfirmationSource: StopConfirmationSource = .stop
    @State private var shouldResumeAfterCancel: Bool = false

    private enum StopConfirmationSource {
        case close
        case stop
    }

    // MARK: - Layout
    
    @ScaledMetric(relativeTo: .title3) private var intervalMessageHeightRegular: CGFloat = 120
    @ScaledMetric(relativeTo: .title3) private var intervalMessageHeightCompact: CGFloat = 64

    private var isCompactVertical: Bool {
        verticalSizeClass == .compact
    }

    private var sectionSpacing: CGFloat {
        Constants.l
    }

    private var innerSpacing: CGFloat {
        isCompactVertical ? Constants.xs : Constants.m
    }

    private var horizontalPadding: CGFloat {
        isCompactVertical ? Constants.m : Constants.l
    }

    private var timerFontSize: CGFloat {
        Constants.xxxl
    }
    
    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                switch viewState {
                case .loading:
                    loadingView
                case .loaded(let workout):
                    playbackContent(workout: workout)
                case .error(let errorMessage):
                    errorView(error: errorMessage)
                }
            }
            .navigationTitle(workoutTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if engine.playbackState == .finished {
                            dismiss()
                        } else if engine.playbackState == .running || engine.playbackState == .paused {
                            presentStopPrompt(source: .close, pauseIfRunning: false)
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel(Copy.accessibility.close)
                }
                Controls(
                    engine: engine,
                    isStopConfirmationPresented: stopConfirmationBindingForControls
                )
            }
            .bluetoothStatus(using: bluetooth)
            .alert(isPresented: $isStopConfirmationPresented) {
                Alert(
                    title: Text(Copy.workoutPlayback.stopRideDialogTitle),
                    primaryButton: .destructive(
                        Text(Copy.workoutPlayback.stopRideDialogStop),
                        action: handleStopConfirmation
                    ),
                    secondaryButton: .cancel(
                        Text(Copy.workoutPlayback.stopRideDialogCancel),
                        action: handleStopCancel
                    ))
            }
            .safeAreaInset(edge: .bottom) {
                if engine.playbackState == .finished {
                    Color.clear
                        .frame(height: 44)
                        .accessibilityHidden(true)
                }
            }
        }
        .task {
            guard autoLoad else { return }
            engine.load(source: workoutSource)
            engine.setPowerProvider { bluetooth.metrics.powerWatts }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background && newPhase == .active {
                engine.updateForForeground()
            }
        }
        .onChange(of: engine.playbackState) { oldState, newState in
            _ = (oldState, newState)
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: Constants.m) {
            ProgressView()
            Text(Copy.workoutPlayback.loadingWorkout)
                .font(.headline)
        }
        .accessibilityElement(children: .combine)
    }

    private func errorView(error: String) -> some View {
        VStack(spacing: Constants.l + Constants.xxs) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text(Copy.workoutPlayback.errorLoadingWorkout)
                .font(.headline)

            Text(error)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(horizontalPadding)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Playback

    private func playbackContent(workout: Workout) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: sectionSpacing) {
                if engine.workout?.hasIntervals == true {
                    intervalContent
                } else {
                    Spacer(minLength: 0)
                }
                
                if !isCompactVertical {
                    metricsGrid
                }
                Spacer(minLength: 0)
                timer
                progressBar
                    .padding(.bottom, Constants.xl)
            }
            .padding(.top, Constants.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isCompactVertical {
                metricsGrid
            }
        }
    }

    // MARK: - Subviews
    
    @ViewBuilder
    private var progressBar: some View {
        ProgressView(value: engine.intervalProgress)
            .foregroundStyle(.primary)
            .padding(.vertical, Constants.s)
            .edgesIgnoringSafeArea(.all)
            .accessibilityLabel(Copy.accessibility.workoutProgress)
    }

    @ViewBuilder
    private var intervalContent: some View {
        Group {
            if engine.playbackState == .finished {
                VStack(spacing: innerSpacing) {
                    Text(Copy.workoutPlayback.workoutComplete)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }
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
        .frame(
            height: isCompactVertical ? intervalMessageHeightCompact : intervalMessageHeightRegular,
            alignment: .top
        )
        .padding(.horizontal, horizontalPadding)
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
            .padding(.horizontal, isCompactVertical ? Constants.xxxl * 2 : 0)
    }

    @ViewBuilder
    private var timer: some View {
        Text(formatElapsedTime(engine.isOpenEnded ? engine.elapsedTimeInInterval : engine.remainingTimeInInterval))
            .font(.system(size: timerFontSize, weight: .semibold))
            .monospacedDigit()
            .dynamicTypeSize(.large)
            .animation(.easeInOut(duration: 0.2), value: engine.isOpenEnded ? engine.elapsedTimeInInterval : engine.remainingTimeInInterval)
            .accessibilityLabel("\(engine.isOpenEnded ? Copy.accessibility.elapsedTime : Copy.accessibility.timeRemaining): \(formatElapsedTime(engine.isOpenEnded ? engine.elapsedTimeInInterval : engine.remainingTimeInInterval))")
    }
    
    /// Determines which metrics to display based on playback state and layout context.
    ///
    /// This property handles all metric selection logic for both regular and compact layouts:
    ///
    /// **Finished State:**
    /// - Uses `workout.finishedMetrics` if available (typically average power, heart rate)
    /// - Falls back to `[.averagePower, .heartRate]` if not defined
    /// - Shows all finished metrics regardless of layout (compact or regular)
    ///
    /// **Active/Paused State:**
    /// - Prioritizes custom metrics from `workout.metrics` if defined
    /// - Automatically adds `.targetZone` for interval workouts if not already present
    /// - Falls back to default metrics: `[.zone, .power, .cadence, .heartRate]` (+ `.targetZone` for intervals)
    ///
    /// **Compact Layout Optimization:**
    /// - In compact vertical mode (landscape), limits to first 2 metrics during active playback
    /// - Finished state always shows all metrics even in compact mode
    /// - Regular layout always shows all metrics
    private var metrics: [Metric] {
        // Determine base metrics
        let baseMetrics: [Metric]
        if engine.playbackState == .finished {
            baseMetrics = engine.workout?.finishedMetrics ?? [.averagePower, .heartRate]
        } else if let m = engine.workout?.metrics, !m.isEmpty {
            var list = m
            if engine.workout?.hasIntervals == true, !m.contains(.targetZone) {
                list = list + [.targetZone]
            }
            baseMetrics = list
        } else {
            var defaultMetrics: [Metric] = [.zone, .power, .cadence, .heartRate]
            if engine.workout?.hasIntervals == true { defaultMetrics.append(.targetZone) }
            baseMetrics = defaultMetrics
        }
        
        // Limit metrics for compact layout during active playback
        if isCompactVertical && engine.playbackState != .finished {
            return baseMetrics.count <= 2 ? baseMetrics : Array(baseMetrics.prefix(2))
        }
        
        return baseMetrics
    }
    private var workoutTitle: String {
        engine.workout?.name ?? Copy.placeholder.empty
    }
    
    private var metricsGrid: some View {
        MetricsGrid(
            bluetooth: bluetooth,
            targetZoneLabel: engine.currentInterval?.powerTarget?.zones().zoneLabel,
            zoneTitle: Copy.metrics.currentZone,
            metrics: metrics,
            averagePowerLabel: engine.playbackState == .finished ? averagePowerLabel : nil,
            maxHeartRate: previewMaxHeartRate,
            columnsPerRow: isCompactVertical ? 1 : 2,
            fontSize: isCompactVertical ? 12 : 18,
            maxHeight: isCompactVertical ? 80 : 120,
            maxWidth: isCompactVertical ? 120 : .infinity
        )
        .padding(.horizontal, isCompactVertical ? 0 : horizontalPadding)
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
        guard let avg = engine.averagePowerWatts else { return Copy.placeholder.missingValue }
        return "\(avg) W"
    }

    private var stopConfirmationBindingForControls: Binding<Bool> {
        Binding(
            get: { isStopConfirmationPresented },
            set: { newValue in
                if newValue {
                    presentStopPrompt(source: .stop, pauseIfRunning: true)
                }
                isStopConfirmationPresented = newValue
            }
        )
    }

    private func handleStopConfirmation() {
        isStopConfirmationPresented = false
        shouldResumeAfterCancel = false
        if stopConfirmationSource == .close {
            dismiss()
        }
        Task { @MainActor in
            await Task.yield()
            engine.finish()
        }
    }

    private func handleStopCancel() {
        isStopConfirmationPresented = false
        if stopConfirmationSource == .stop, shouldResumeAfterCancel {
            engine.start()
        }
        shouldResumeAfterCancel = false
    }

    private func presentStopPrompt(source: StopConfirmationSource, pauseIfRunning: Bool) {
        stopConfirmationSource = source
        if pauseIfRunning, engine.playbackState == .running {
            shouldResumeAfterCancel = true
            engine.pause()
        } else {
            shouldResumeAfterCancel = false
        }
        isStopConfirmationPresented = true
    }

}

#Preview("Interval Workout") {
    WorkoutPlaybackPreviewHost()
}

#Preview("Just Ride") {
    WorkoutPlaybackJustRidePreviewHost(playbackState: .idle)
}

private struct WorkoutPlaybackPreviewHost: View {
    let playbackState: PlaybackState?
    @StateObject private var engine: WorkoutEngine
    
    private var bluetooth: BluetoothManager {
        let bluetooth = BluetoothManager()
        bluetooth.metrics.heartRateBpm = 150
        bluetooth.metrics.powerWatts = 110
        bluetooth.metrics.cadenceRpm = 69
        return bluetooth
    }

    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        let settings = PreviewData.userSettings()
        // Set maxHR for heart rate meter preview
        settings.maxHR = 180
        context.insert(settings)
        try? context.save()
        return c
    }()

    private static let previewWorkoutSource: WorkoutSource = {
        let zwo = """
        <workout_file>
            <name>Preview Workout</name>
            <workout>
                <SteadyState Duration="300" Power="0.5" pace="0">
                    <textevent timeoffset="0" message="Welcome! Let's warm up at an easy pace. This is a longer warmup than usual to support bloodflow and mental readiness."/>
                </SteadyState>
                <SteadyState Duration="180" Power="0.75" pace="0">
                    <textevent timeoffset="0" message="Building intensity now. Find your rhythm."/>
                </SteadyState>
                <IntervalsT Repeat="3" OnDuration="60" OffDuration="60" OnPower="0.95" OffPower="0.5" pace="0">
                    <textevent timeoffset="0" message="Push hard! Give it everything you've got!"/>
                    <textevent timeoffset="60" message="Recovery time. Catch your breath."/>
                </IntervalsT>
                <SteadyState Duration="240" Power="0.6" pace="0">
                    <textevent timeoffset="0" message="Great work! Cool down at an easy pace."/>
                </SteadyState>
            </workout>
        </workout_file>
        """
        let data = Data(zwo.utf8)
        return ZwiftWorkoutSource(id: "preview", data: data)
    }()

    @MainActor
    init(playbackState: PlaybackState? = nil) {
        self.playbackState = playbackState
        _engine = StateObject(wrappedValue: WorkoutEngine())
    }

    var body: some View {
        NavigationStack {
            WorkoutPlayback(
                workoutSource: Self.previewWorkoutSource,
                autoLoad: false,
                engine: engine,
                previewMaxHeartRate: 180
            )
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
        .task {
            engine.load(source: Self.previewWorkoutSource)
            engine.setPowerProvider { bluetooth.metrics.powerWatts }
            applyPreviewPlaybackState(playbackState)
        }
    }

    private func applyPreviewPlaybackState(_ state: PlaybackState?) {
        guard let state else { return }
        switch state {
        case .finished:
            engine.finish()
        case .idle:
            engine.restart()
        case .paused:
            engine.pause()
        case .running:
            engine.start()
        }
    }
}

private struct WorkoutPlaybackJustRideHost: View {
    let playbackState: PlaybackState
    @StateObject private var engine: WorkoutEngine
    private var bluetooth: BluetoothManager {
        PreviewData.bluetoothManager()
    }

    private let container: ModelContainer = {
        let c = try! ModelContainer(for: UserSettings.self)
        let context = c.mainContext
        let settings = PreviewData.userSettings()
        // Set maxHR for heart rate meter preview
        settings.maxHR = 180
        context.insert(settings)
        try? context.save()
        return c
    }()

    @MainActor
    init(playbackState: PlaybackState) {
        self.playbackState = playbackState
        _engine = StateObject(wrappedValue: WorkoutEngine())
    }

    var body: some View {
        NavigationStack {
            WorkoutPlayback(
                workoutSource: JustRideWorkoutSource(),
                autoLoad: false,
                engine: engine,
                previewMaxHeartRate: 180
            )
        }
        .modelContainer(container)
        .environmentObject(bluetooth)
        .task {
            engine.load(source: JustRideWorkoutSource())
            engine.setPowerProvider { bluetooth.metrics.powerWatts }
            applyPreviewPlaybackState(playbackState)
        }
    }

    private func applyPreviewPlaybackState(_ state: PlaybackState) {
        switch state {
        case .finished:
            engine.finish()
        case .idle:
            engine.restart()
        case .paused:
            engine.pause()
        case .running:
            engine.start()
        }
    }
}

@MainActor
private func WorkoutPlaybackJustRidePreviewHost(playbackState: PlaybackState) -> some View {
    WorkoutPlaybackJustRideHost(playbackState: playbackState)
}

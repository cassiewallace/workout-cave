//
//  WorkoutEngine.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import Foundation
import Combine

enum PlaybackState {
    case idle
    case running
    case paused
    case finished
}

@MainActor
class WorkoutEngine: ObservableObject {
    // MARK: - Properties
    
    @Published var currentIntervalIndex: Int = 0
    @Published var elapsedTimeInInterval: TimeInterval = 0
    @Published var playbackState: PlaybackState = .idle
    @Published var workout: Workout?
    @Published var errorMessage: String?
    
    @Published private(set) var averagePowerWatts: Int?
    
    private var intervalStartTime: Date?
    private var pausedElapsedTime: TimeInterval = 0
    private var timer: Timer?
    
    // Power averaging (excluding 0 W)
    private var powerProvider: (() -> Int?)?
    private var avgWattSeconds: Double = 0
    private var avgValidSeconds: Double = 0
    private var avgLastSampleDate: Date?
    private var avgTimer: Timer?
    
    var currentInterval: Workout.Interval? {
        guard let workout = workout,
              currentIntervalIndex >= 0,
              currentIntervalIndex < workout.intervals.count else {
            return nil
        }
        return workout.intervals[currentIntervalIndex]
    }
    
    var remainingTimeInInterval: TimeInterval {
        guard let interval = currentInterval else { return 0 }
        return max(0, interval.duration - elapsedTimeInInterval)
    }

    var isJustRide: Bool {
        workout?.isJustRide == true
    }
    
    var intervalProgress: Double {
        guard let workout = workout else { return 0 }

        if playbackState == .finished {
            return 1.0
        }

        let completedIntervalsTime = workout.intervals
            .prefix(currentIntervalIndex)
            .reduce(0) { $0 + $1.duration }

        let currentIntervalElapsed = min(
            elapsedTimeInInterval,
            workout.intervals[currentIntervalIndex].duration
        )

        let totalElapsed = completedIntervalsTime + currentIntervalElapsed
        let totalDuration = workout.totalDuration

        guard totalDuration > 0 else { return 0 }

        return min(totalElapsed / totalDuration, 1.0)
    }
    
    // MARK: - Lifecycle
    
    deinit {
        // Timer.invalidate() is thread-safe, so we can call it directly
        timer?.invalidate()
        avgTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func load(source: WorkoutSource) {
        do {
            workout = try source.loadWorkout()
            reset()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setPowerProvider(_ provider: @escaping () -> Int?) {
        powerProvider = provider
    }
    
    func start() {
        guard playbackState != .running else { return }
        
        if playbackState == .paused {
            // Resume from pause
            intervalStartTime = Date()
            playbackState = .running
            startTimer()
            startAverageTimer(reset: false)
        } else {
            // Start fresh
            reset()
            currentIntervalIndex = 0
            elapsedTimeInInterval = 0
            intervalStartTime = Date()
            playbackState = .running
            startTimer()
            startAverageTimer(reset: true)
        }
    }
    
    func pause() {
        guard playbackState == .running else { return }
        
        stopTimer()
        stopAverageTimer()
        pausedElapsedTime = elapsedTimeInInterval
        intervalStartTime = nil
        playbackState = .paused
    }
    
    func skipInterval() {
        guard let workout = workout else { return }
        
        stopTimer()
        
        if currentIntervalIndex < workout.intervals.count - 1 {
            currentIntervalIndex += 1
            elapsedTimeInInterval = 0
            pausedElapsedTime = 0
            
            if playbackState == .running {
                intervalStartTime = Date()
                startTimer()
            }
        } else {
            finish()
        }
    }
    
    func restart() {
        stopTimer()
        stopAverageTimer()
        reset()
    }
    
    func finish() {
        stopTimer()
        stopAverageTimer()
        playbackState = .finished
        intervalStartTime = nil
    }
    
    func updateForForeground() {
        guard playbackState == .running,
              let intervalStartTime = intervalStartTime,
              let interval = currentInterval else {
            return
        }
        
        // Recalculate elapsed time based on wall-clock time
        let now = Date()
        let totalElapsed = pausedElapsedTime + now.timeIntervalSince(intervalStartTime)
        elapsedTimeInInterval = totalElapsed
        
        // If interval completed while in background, advance
        if elapsedTimeInInterval >= interval.duration {
            advanceToNextInterval()
        }
    }
    
    // MARK: - Private Methods
    
    private func reset() {
        currentIntervalIndex = 0
        elapsedTimeInInterval = 0
        pausedElapsedTime = 0
        intervalStartTime = nil
        playbackState = .idle
        resetAveragePower()
    }
    
    private func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateElapsedTime()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard playbackState == .running,
              let intervalStartTime = intervalStartTime,
              let interval = currentInterval else {
            return
        }
        
        // Calculate elapsed time based on wall-clock time
        let now = Date()
        let totalElapsed = pausedElapsedTime + now.timeIntervalSince(intervalStartTime)
        elapsedTimeInInterval = totalElapsed
        
        // Check if interval is complete
        if elapsedTimeInInterval >= interval.duration {
            advanceToNextInterval()
        }
    }
    
    private func advanceToNextInterval() {
        guard let workout = workout else { return }
        
        if currentIntervalIndex < workout.intervals.count - 1 {
            currentIntervalIndex += 1
            elapsedTimeInInterval = 0
            pausedElapsedTime = 0
            intervalStartTime = Date()
        } else {
            finish()
        }
    }
    
    private func startAverageTimer(reset: Bool) {
        if reset {
            resetAveragePower()
        }
        
        guard avgTimer == nil else { return }
        
        avgLastSampleDate = Date()
        avgTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.recordAverageSample()
            }
        }
    }
    
    private func stopAverageTimer() {
        avgTimer?.invalidate()
        avgTimer = nil
        avgLastSampleDate = nil
    }
    
    private func resetAveragePower() {
        avgWattSeconds = 0
        avgValidSeconds = 0
        averagePowerWatts = nil
    }
    
    private func recordAverageSample() {
        guard playbackState == .running else { return }
        guard let powerProvider else { return }
        
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
        
        if let watts = powerProvider(), watts > 0 {
            avgWattSeconds += Double(watts) * dt
            avgValidSeconds += dt
            averagePowerWatts = Int((avgWattSeconds / avgValidSeconds).rounded())
        }
        
        avgLastSampleDate = now
    }
}


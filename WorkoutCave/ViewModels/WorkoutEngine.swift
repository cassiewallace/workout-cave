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
    
    private var workout: Workout?
    private var intervalStartTime: Date?
    private var pausedElapsedTime: TimeInterval = 0
    private var timer: Timer?
    
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
    
    var intervalProgress: String {
        guard let workout = workout else { return "" }
        return "Interval \(currentIntervalIndex + 1) of \(workout.intervals.count)"
    }
    
    // MARK: - Lifecycle
    
    deinit {
        // Timer.invalidate() is thread-safe, so we can call it directly
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func loadWorkout(_ workout: Workout) {
        self.workout = workout
        reset()
    }
    
    func start() {
        guard playbackState != .running else { return }
        
        if playbackState == .paused {
            // Resume from pause
            intervalStartTime = Date()
            playbackState = .running
            startTimer()
        } else {
            // Start fresh
            reset()
            currentIntervalIndex = 0
            elapsedTimeInInterval = 0
            intervalStartTime = Date()
            playbackState = .running
            startTimer()
        }
    }
    
    func pause() {
        guard playbackState == .running else { return }
        
        stopTimer()
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
            // Last interval, finish workout
            finishWorkout()
        }
    }
    
    func restart() {
        stopTimer()
        reset()
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
            finishWorkout()
        }
    }
    
    private func finishWorkout() {
        stopTimer()
        playbackState = .finished
        intervalStartTime = nil
    }
}


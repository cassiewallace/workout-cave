//
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
    var workoutName: String
    
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
            engine.loadWorkout(workoutName)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background && newPhase == .active {
                engine.updateForForeground()
            }
        }
    }
    
    // MARK: - Private Views
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading workout...")
                .font(.headline)
                .padding(.top)
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
                .padding(.horizontal)
        }
    }
    
    private func playbackContent(workout: Workout) -> some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.width < 500
            let spacing: CGFloat = isCompact ? 20 : 40
            let horizontalPadding: CGFloat = isCompact ? 20 : 40
            let intervalFontSize = isCompact ? 
                min(geometry.size.width * 0.12, 48) : 
                min(geometry.size.width * 0.15, 72)
            let timerFontSize = isCompact ?
                min(geometry.size.width * 0.10, 48) :
                min(geometry.size.width * 0.12, 64)
            
            VStack(spacing: spacing) {
                // Workout name
                Text(workout.name)
                    .font(isCompact ? .title3 : .title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.top, isCompact ? 10 : 20)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                // Interval progress
                if engine.playbackState == .finished {
                    Text("Workout Complete")
                        .font(isCompact ? .body : .title3)
                        .foregroundColor(.secondary)
                } else {
                    Text(engine.intervalProgress)
                        .font(isCompact ? .body : .title3)
                        .foregroundColor(.secondary)
                }
                
                // Interval name (large, centered)
                if engine.playbackState == .finished {
                    Text("Finished")
                        .font(.system(size: intervalFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.green)
                } else if let interval = engine.currentInterval {
                    Text(interval.name)
                        .font(.system(size: intervalFontSize, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                }
                
                // Countdown timer
                if engine.playbackState != .finished {
                    Text(formatTime(engine.remainingTimeInInterval))
                        .font(.system(size: timerFontSize, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .padding(.vertical, isCompact ? 10 : 20)
                }
                
                Spacer()
                
                // Controls
                VStack(spacing: isCompact ? 12 : 20) {
                    // Start/Pause button
                    Button(action: {
                        if engine.playbackState == .running {
                            engine.pause()
                        } else {
                            engine.start()
                        }
                    }) {
                        HStack {
                            Image(systemName: engine.playbackState == .running ? "pause.fill" : "play.fill")
                            Text(engine.playbackState == .running ? "Pause" : "Start")
                        }
                        .font(isCompact ? .headline : .title2)
                        .frame(maxWidth: .infinity)
                        .padding(isCompact ? 12 : 16)
                        .background(engine.playbackState == .finished ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(engine.playbackState == .finished)
                    
                    if isCompact {
                        // Stack buttons vertically in compact width
                        VStack(spacing: 12) {
                            Button(action: {
                                engine.skipInterval()
                            }) {
                                HStack {
                                    Image(systemName: "forward.fill")
                                    Text("Skip Interval")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(engine.playbackState == .idle || engine.playbackState == .finished)
                            
                            Button(action: {
                                engine.restart()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Restart")
                                }
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(engine.playbackState == .idle)
                        }
                    } else {
                        // Side-by-side buttons in wider layouts
                        HStack(spacing: 20) {
                            // Skip interval button
                            Button(action: {
                                engine.skipInterval()
                            }) {
                                HStack {
                                    Image(systemName: "forward.fill")
                                    Text("Skip Interval")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(engine.playbackState == .idle || engine.playbackState == .finished)
                            
                            // Restart button
                            Button(action: {
                                engine.restart()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Restart")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(engine.playbackState == .idle)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.bottom, isCompact ? 20 : 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    WorkoutPlayback(workoutName: "sample")
}


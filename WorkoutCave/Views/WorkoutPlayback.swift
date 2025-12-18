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
    
    var spacing: CGFloat = 24
    var timerFontSize: CGFloat = 128
    
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
        VStack(spacing: spacing) {
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
        ScrollView {
            VStack(spacing: spacing) {
                Text(workout.name)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.top, spacing)
                    .lineLimit(2)
                
                Spacer()
                
                if engine.playbackState == .finished {
                    Text("Workout Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.green)
                } else if let interval = engine.currentInterval {
                    Text(interval.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .lineLimit(3)
                    if let message = interval.message {
                        Text(message)
                            .font(.title)
                    }
                }
                
                Spacer()
                
                // Countdown timer
                if engine.playbackState != .finished {
                    Text(formatTime(engine.remainingTimeInInterval))
                        .font(.custom("Timer", size: timerFontSize))
                        .fontWeight(.bold)
                        .dynamicTypeSize(.large)
                        .monospacedDigit()
                }
            }
            .padding([.horizontal, .bottom], spacing)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: spacing) {
                ProgressView(value: engine.intervalProgress)
                Controls(engine: engine)
            }
        }
        .safeAreaPadding(.bottom, spacing)
    }
    
    // MARK: - Private Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview("Landscape", traits: .landscapeLeft) {
    WorkoutPlayback(workoutName: "jen-intervals")
}


#Preview("Portrait", traits: .portrait) {
    WorkoutPlayback(workoutName: "jen-intervals")
}


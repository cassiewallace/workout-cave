//
//  Controls.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftUI

struct Controls: ToolbarContent {
    @ObservedObject var engine: WorkoutEngine
    var isJustRide: Bool
    @Binding var isStopConfirmationPresented: Bool
    var onStopConfirmed: () -> Void
    var onRestart: () -> Void
    
    @ToolbarContentBuilder
    var body: some ToolbarContent {
        if engine.workout != nil {
            if !isJustRide {
                ToolbarItem(placement: .bottomBar) {
                    Control(
                        controlType: .skip,
                        action: engine.skipInterval,
                        isDisabled: engine.playbackState == .idle || engine.playbackState == .finished
                    )
                }
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
            
            if isJustRide {
                ToolbarItem(placement: .bottomBar) {
                    Control(
                        controlType: .stop,
                        action: { isStopConfirmationPresented = true },
                        isDisabled: engine.playbackState == .idle || engine.playbackState == .finished
                    )
                    .confirmationDialog(
                        Copy.workoutPlayback.stopRideDialogTitle,
                        isPresented: $isStopConfirmationPresented,
                        titleVisibility: .visible
                    ) {
                        Button(Copy.workoutPlayback.stopRideDialogStop, role: .destructive) {
                            onStopConfirmed()
                        }
                        Button(Copy.workoutPlayback.stopRideDialogCancel, role: .cancel) {}
                    }
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Control(
                    controlType: .restart,
                    action: onRestart,
                    isDisabled: engine.playbackState == .idle
                )
            }
        }
    }
}

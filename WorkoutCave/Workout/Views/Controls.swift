//
//  Controls.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/19/26.
//

import SwiftUI

struct Controls: ToolbarContent {
    @ObservedObject var engine: WorkoutEngine
    @Binding var isStopConfirmationPresented: Bool
    
    @ToolbarContentBuilder
    var body: some ToolbarContent {
        if let workout = engine.workout {
            if !workout.isJustRide && (engine.playbackState == .running || engine.playbackState == .paused) {
                ToolbarItem(placement: .bottomBar) {
                    Control(
                        controlType: .skip,
                        action: engine.skipInterval,
                        isDisabled: engine.playbackState == .idle || engine.playbackState == .finished
                    )
                }
            }
            
            if engine.playbackState == .running || engine.playbackState == .paused {
                ToolbarItem(placement: .bottomBar) {
                    Control(
                        controlType: .stop,
                        action: { isStopConfirmationPresented = true },
                        isDisabled: false
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

        }
    }
}

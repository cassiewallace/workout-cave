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
    var onStopTap: () -> Void
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
                        action: onStopTap,
                        isDisabled: engine.playbackState == .idle || engine.playbackState == .finished
                    )
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

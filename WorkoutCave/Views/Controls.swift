//
//  Controls.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

// MARK: - Enumerations

private enum ControlType {
    case play
    case pause
    case skip
    case restart
}

struct Controls: View {
    // MARK: - Properties
    
    @ObservedObject var engine: WorkoutEngine
    private let spacing: CGFloat = 64
    
    var body: some View {
        HStack(spacing: spacing) {
            Control(controlType: ControlType.skip, action: engine.skipInterval)
                .disabled(engine.playbackState == .idle || engine.playbackState == .finished)
            if engine.playbackState == .running {
                Control(controlType: ControlType.pause, action: engine.pause)
                    .disabled(engine.playbackState == .finished)
            } else if engine.playbackState == .paused || engine.playbackState == .idle {
                Control(controlType: ControlType.play, action: engine.start)
                    .disabled(engine.playbackState == .finished)
            }
            Control(controlType: ControlType.restart, action: engine.restart)
                .disabled(engine.playbackState == .idle)
        }
    }
}

private struct Control: View {
    // MARK: - Properties
    
    var controlType: ControlType
    var action: () -> Void
    
    private let buttonSize: CGFloat = 44
    
    private var image: Image {
        switch controlType {
        case .play: Image(systemName: "play.circle.fill")
        case .pause: Image(systemName: "pause.circle.fill")
        case .skip: Image(systemName: "forward.circle")
        case .restart: Image(systemName: "arrow.counterclockwise.circle")
        }
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            image
                .resizable()
                .frame(width: buttonSize, height: buttonSize)
        }
        .foregroundColor(.black)
    }
}

#Preview {
    var engine: WorkoutEngine {
        let engine = WorkoutEngine()
        engine.playbackState = .paused
        return engine
    }
    
    Controls(engine: engine)
        .padding()
}

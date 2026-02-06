//
//  Control.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

// MARK: - Enumerations

enum ControlType {
    case play
    case pause
    case skip
    case stop
}

struct Control: View {
    // MARK: - Properties
    
    var controlType: ControlType
    var action: () -> Void
    var isDisabled: Bool
    
    private let buttonSize: CGFloat = 44
    
    private var image: Image {
        switch controlType {
        case .play: Image(systemName: "play.fill")
        case .pause: Image(systemName: "pause.fill")
        case .skip: Image(systemName: "forward")
        case .stop: Image(systemName: "stop.fill")
        }
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            image
                .frame(width: buttonSize, height: buttonSize)
        }
        .foregroundStyle(.primary)
        .disabled(isDisabled)
    }
}

#Preview {
    var engine: WorkoutEngine {
        let engine = WorkoutEngine()
        engine.playbackState = .paused
        return engine
    }
    
    HStack {
        Control(controlType: .pause, action: {}, isDisabled: false)
        Control(controlType: .play, action: {}, isDisabled: false)
        Control(controlType: .skip, action: {}, isDisabled: false)
        Control(controlType: .stop, action: {}, isDisabled: false)
    }
}

//
//  Controls.swift
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
    case restart
}

struct Control: View {
    // MARK: - Properties
    
    var controlType: ControlType
    var action: () -> Void
    var isDisabled: Bool
    
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
        .foregroundStyle(.primary)
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
        Control(controlType: .restart, action: {}, isDisabled: false)
        Control(controlType: .skip, action: {}, isDisabled: false)
    }
}

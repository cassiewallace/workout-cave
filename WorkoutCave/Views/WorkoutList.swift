//
//  WorkoutList.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

struct WorkoutList: View {
    // MARK: - Properties
    
    private var workouts: [String] = ["sample"]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List(workouts, id: \.self) { workout in
                NavigationLink(destination: WorkoutPlayback(workoutName: workout)) {
                    Text(workout)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Workout List") {
    WorkoutList()
}

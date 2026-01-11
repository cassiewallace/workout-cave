//
//  WorkoutTile.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/11/26.
//

import SwiftUI

struct WorkoutCard: View {
    var name: String
    var description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline)
                .foregroundColor(.primary)
            Text(description)
                .foregroundColor(.primary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quinary.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary, lineWidth: 1)
        )
    }
}

#Preview {
    WorkoutCard(name: "Monday Interval Workout", description: "A 30-minute workout with high-intensity intervals.")
        .padding()
}

//
//  WorkoutTile.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/11/26.
//

import SwiftUI

struct WorkoutCard: View {
    var name: String
    var description: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.xs) {
            Text(name)
                .font(.title2)
                .bold()
                .foregroundStyle(Color("CardTitle"))
            if let description, !description.isEmpty {
                Text(description)
                    .foregroundStyle(Color("CardSubtitle"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .styledCard()
    }
}

#Preview {
    WorkoutCard(name: "40:20s Interval Workout", description: "A 30-minute workout with high-intensity intervals.")
        .padding()
}

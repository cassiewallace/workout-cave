//
//  WorkoutList.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

private enum SortOrder: String, CaseIterable {
    case recommended
    case name
}

struct WorkoutList: View {
    // MARK: - Properties

    private let items = WorkoutCatalog.all()
    @State private var workouts: [LoadedWorkout] = []
    @State private var selectedWorkout: LoadedWorkout? = nil
    @State private var sortOrder: SortOrder = .recommended
    
    private var filteredWorkouts: [LoadedWorkout] {
        workouts.sorted {
            switch sortOrder {
            case .recommended: return false
            case .name: return $0.workout.name.localizedStandardCompare($1.workout.name) == .orderedAscending
            }
        }
    }


    // MARK: - Body

    var body: some View {
        List {
            ForEach(filteredWorkouts) { workout in
                Button {
                    selectedWorkout = workout
                } label: {
                    WorkoutCard(name: workout.workout.name,
                                description: workout.workout.description)
                }
            }
            .listRowInsets(.init(top: Constants.xs, leading: Constants.l, bottom: Constants.xs, trailing: Constants.l))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .fullScreenCover(item: $selectedWorkout) { workout in
            WorkoutPlayback(workoutSource: workout.source)
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Copy.navigationTitle.workouts)
        .navigationBarTitleDisplayMode(.large)
        .background(Color.orange.opacity(0.3))
        .task {
            workouts = items.compactMap { item in
                guard let workout = try? item.source.loadWorkout() else {
                    return nil
                }
                return LoadedWorkout(id: item.id, workout: workout, source: item.source)
            }
        }
        .toolbar {
            Menu {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { sortOrder in
                        Text(sortOrder.rawValue.capitalized).tag(sortOrder)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
            }
        }
    }
}

#Preview("Workout List", traits: .portrait) {
    NavigationStack {
        WorkoutList()
    }
}

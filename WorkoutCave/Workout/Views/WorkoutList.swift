//
//  WorkoutList.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 12/18/25.
//

import SwiftUI

struct WorkoutList: View {
    // MARK: - Types

    private enum SortOrder: String, CaseIterable {
        case recommended
        case name
    }

    private enum ViewState {
        case loading
        case loaded([WorkoutListItem])
        case error(String)
    }

    private struct WorkoutListItem: Identifiable {
        let id: String
        let name: String
        let description: String?
        let source: WorkoutListSource
    }

    private enum WorkoutListSource {
        case local(LoadedWorkout)
        case remote(id: Int)
    }

    // MARK: - Properties

    private static let localWorkoutSources: [(id: String, source: WorkoutSource)] = [
        (Workout.justRideId, JustRideWorkoutSource())
    ]

    private let workoutAPI = WorkoutAPI()

    @EnvironmentObject private var bluetooth: BluetoothManager
    @State private var viewState: ViewState = .loading
    @State private var selectedWorkout: LoadedWorkout?
    @State private var sortOrder: SortOrder = .recommended
    @State private var searchText: String = ""
    @State private var isLoadingSelection = false

    // MARK: - Computed Properties

    private var filteredWorkouts: [WorkoutListItem] {
        guard case let .loaded(items) = viewState else { return [] }
        return items
            .filter { searchText.isEmpty || $0.name.localizedStandardContains(searchText) }
            .sorted {
                switch sortOrder {
                case .recommended:
                    return false
                case .name:
                    return $0.name.localizedStandardCompare($1.name) == .orderedAscending
                }
            }
    }

    var body: some View {
        List {
            switch viewState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            case .error(let message):
                Text(message)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            case .loaded:
                if filteredWorkouts.isEmpty {
                    Text("No workouts available.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredWorkouts) { item in
                        Button {
                            handleSelection(item)
                        } label: {
                            WorkoutCard(
                                name: item.name,
                                description: item.description
                            )
                        }
                        .disabled(isLoadingSelection)
                    }
                    .listRowInsets(.init(top: Constants.xs, leading: Constants.l, bottom: Constants.xs, trailing: Constants.l))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
        .fullScreenCover(item: $selectedWorkout) { workout in
            WorkoutPlayback(workoutSource: workout.source)
                .environmentObject(bluetooth)
        }
        .listStyle(.plain)
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(Copy.navigationTitle.workouts)
        .navigationBarTitleDisplayMode(.large)
        .background(Color("AppBackground"))
        .task {
            viewState = .loading
            let local: [WorkoutListItem] = Self.localWorkoutSources.compactMap { item in
                guard let workout = try? item.source.loadWorkout() else {
                    return nil
                }
                let loaded = LoadedWorkout(id: item.id, workout: workout, source: item.source)
                return WorkoutListItem(
                    id: item.id,
                    name: workout.name,
                    description: workout.description,
                    source: .local(loaded)
                )
            }

            do {
                let remote = try await workoutAPI.fetchWorkoutSummaries()
                let remoteItems = remote.map { summary in
                    WorkoutListItem(
                        id: "remote-\(summary.id)",
                        name: summary.name,
                        description: summary.description,
                        source: .remote(id: summary.id)
                    )
                }
                viewState = .loaded(local + remoteItems)
            } catch {
                viewState = .loaded(local)
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
        .searchable(text: $searchText)
    }

    // MARK: - Actions

    private func handleSelection(_ item: WorkoutListItem) {
        switch item.source {
        case .local(let loaded):
            selectedWorkout = loaded
        case .remote(let id):
            isLoadingSelection = true
            Task {
                do {
                    let workout = try await workoutAPI.fetchWorkout(id: id)
                    let loaded = LoadedWorkout(
                        id: String(id),
                        workout: workout,
                        source: NetworkWorkoutSource(workout: workout)
                    )
                    selectedWorkout = loaded
                } catch {
                    viewState = .error(String(describing: error))
                }
                isLoadingSelection = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Workout List", traits: .portrait) {
    NavigationStack {
        WorkoutList()
    }
}

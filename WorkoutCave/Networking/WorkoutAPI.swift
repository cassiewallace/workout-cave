//
//  WorkoutAPI.swift
//  WorkoutCave
//

import FirebaseFirestore

struct WorkoutAPI {
    private let database: Firestore

    init(database: Firestore = NetworkClient.shared.database) {
        self.database = database
    }

    func fetchWorkoutSummaries() async throws -> [WorkoutSummary] {
        let snapshot = try await database.collection("workouts").getDocuments()
        return snapshot.documents.map { doc in
            WorkoutSummary(
                id: doc.documentID,
                name: doc["name"] as? String ?? "",
                description: doc["description"] as? String
            )
        }
    }

    func fetchWorkout(id: String) async throws -> Workout {
        let workoutDoc = try await database.collection("workouts").document(id).getDocument()
        guard workoutDoc.exists, let data = workoutDoc.data() else {
            throw WorkoutAPIError.notFound
        }

        let intervalsSnapshot = try await database
            .collection("workouts").document(id)
            .collection("intervals")
            .order(by: "order_index")
            .getDocuments()

        let intervals = intervalsSnapshot.documents.map { $0.data().toInterval() }
        return data.toWorkout(id: id, intervals: intervals)
    }
}

enum WorkoutAPIError: Error {
    case notFound
}

struct WorkoutSummary: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
}

// MARK: - Firestore Mapping

extension Dictionary where Key == String, Value == Any {
    func toWorkout(id: String, intervals: [Workout.Interval]) -> Workout {
        Workout(
            id: id,
            name: self["name"] as? String ?? "",
            description: self["description"] as? String,
            intervals: intervals,
            duration: (self["duration"] as? Int).map { TimeInterval($0) },
            metrics: (self["metrics"] as? [String])?.compactMap { Metric(rawValue: $0) },
            finishedMetrics: (self["finished_metrics"] as? [String])?.compactMap { Metric(rawValue: $0) }
        )
    }

    func toInterval() -> Workout.Interval {
        let powerLower = self["power_lower"] as? Double
        let powerUpper = self["power_upper"] as? Double
        let powerTarget: Workout.Interval.PowerTarget? = (powerLower != nil || powerUpper != nil)
            ? Workout.Interval.PowerTarget(lowerBound: powerLower, upperBound: powerUpper)
            : nil
        return Workout.Interval(
            duration: TimeInterval((self["duration"] as? Int) ?? 0),
            name: self["name"] as? String ?? "",
            message: self["message"] as? String,
            type: Workout.Interval.IntervalType(rawValue: self["type"] as? String ?? "") ?? .steadyState,
            powerTarget: powerTarget
        )
    }
}

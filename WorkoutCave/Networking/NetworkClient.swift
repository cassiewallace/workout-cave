//
//  NetworkClient.swift
//  WorkoutCave
//

import FirebaseFirestore

final class NetworkClient {
    static let shared = NetworkClient()
    let database = Firestore.firestore()
    private init() {}
}

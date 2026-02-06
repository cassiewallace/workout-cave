//
//  NetworkClient.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation
import Supabase

final class NetworkClient {
    static let shared = NetworkClient()

    let client: SupabaseClient

    private init() {
        let authOptions = SupabaseClientOptions.AuthOptions(
            autoRefreshToken: false,
            emitLocalSessionAsInitialSession: true
        )
        let options = SupabaseClientOptions(auth: authOptions)

        client = SupabaseClient(
            supabaseURL: NetworkConfig.url,
            supabaseKey: NetworkConfig.anonKey,
            options: options
        )
    }
}

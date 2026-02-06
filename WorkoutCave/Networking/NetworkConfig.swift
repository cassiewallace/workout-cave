//
//  NetworkConfig.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/2/26.
//

import Foundation

enum NetworkConfig {
    static var url: URL {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: value), !value.isEmpty else {
            fatalError("Missing SUPABASE_URL in Info.plist")
        }
        return url
    }

    static var anonKey: String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !value.isEmpty else {
            fatalError("Missing SUPABASE_ANON_KEY in Info.plist")
        }
        return value
    }
}

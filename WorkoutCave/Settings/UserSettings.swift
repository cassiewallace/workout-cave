//
//  UserSettings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/11/26.
//

import SwiftData
import SwiftUI

@Model
final class UserSettings {
    @Attribute(.unique) var id: String
    var ftpWatts: Int?

    init(id: String = "me", ftpWatts: Int? = nil) {
        self.id = id
        self.ftpWatts = ftpWatts
    }
}

extension UserSettings {
    func powerZone(for watts: Int?) -> PowerZone? {
        guard let watts, let ftpWatts, ftpWatts > 0 else { return nil }
        return PowerZone.zone(for: watts, ftp: ftpWatts)
    }
}

@MainActor
enum UserSettingsStore {
    static func loadOrCreate(in context: ModelContext) throws -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>(
            predicate: #Predicate { $0.id == "me" }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let settings = UserSettings()
        context.insert(settings)
        try context.save()
        return settings
    }
}

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
    var hasSeenIntro: Bool?
    var speedUnitRawValue: String?

    init(
        id: String = "me",
        ftpWatts: Int? = nil,
        hasSeenIntro: Bool? = nil,
        speedUnitRawValue: String? = nil
    ) {
        self.id = id
        self.ftpWatts = ftpWatts
        self.hasSeenIntro = hasSeenIntro
        self.speedUnitRawValue = speedUnitRawValue
    }
}

enum SpeedUnit: String, CaseIterable, Identifiable {
    case mph
    case kph

    var id: String { rawValue }

    var displayName: String { rawValue }
}

extension UserSettings {
    var speedUnit: SpeedUnit {
        get { SpeedUnit(rawValue: speedUnitRawValue ?? "") ?? .mph }
        set { speedUnitRawValue = newValue.rawValue }
    }

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

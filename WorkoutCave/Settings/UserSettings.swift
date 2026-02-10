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
    var maxHR: Int?
    var hasSeenIntro: Bool?
    var speedUnitRawValue: String?
    var appearanceRawValue: String?

    init(
        id: String = "me",
        ftpWatts: Int? = nil,
        maxHR: Int? = nil,
        hasSeenIntro: Bool? = nil,
        speedUnitRawValue: String? = nil,
        appearanceRawValue: String? = nil
    ) {
        self.id = id
        self.ftpWatts = ftpWatts
        self.maxHR = maxHR
        self.hasSeenIntro = hasSeenIntro
        self.speedUnitRawValue = speedUnitRawValue
        self.appearanceRawValue = appearanceRawValue
    }
}

enum SpeedUnit: String, CaseIterable, Identifiable {
    case mph
    case kph

    var id: String { rawValue }

    var displayName: String { rawValue }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .system:
            return "System"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

extension UserSettings {
    var speedUnit: SpeedUnit {
        get { SpeedUnit(rawValue: speedUnitRawValue ?? "") ?? .mph }
        set { speedUnitRawValue = newValue.rawValue }
    }

    var appAppearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRawValue ?? "") ?? .system }
        set { appearanceRawValue = newValue.rawValue }
    }

    func powerZone(for watts: Int?) -> PowerZone? {
        guard let watts, let ftpWatts, ftpWatts > 0 else { return nil }
        return PowerZone.zone(for: watts, ftp: ftpWatts)
    }

    func heartRateZone(for bpm: Int?) -> HeartRateZone? {
        guard let bpm, let maxHR, maxHR > 0 else { return nil }
        return HeartRateZone.zone(for: bpm, maxHR: maxHR)
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

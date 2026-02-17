//
//  PreviewData.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 2/17/26.
//

public struct PreviewData {
    static func bluetoothManager(heartRateBpm: Int = 121) -> BluetoothManager {
        let manager = BluetoothManager()
        manager.metrics.heartRateBpm = heartRateBpm
        return manager
    }
    
    static func userSettings(ftpWatts: Int = 250, maxHR: Int = 190) -> UserSettings {
        let userSettings = UserSettings(id: "0")
        userSettings.ftpWatts = ftpWatts
        userSettings.maxHR = maxHR
        return userSettings
    }
}

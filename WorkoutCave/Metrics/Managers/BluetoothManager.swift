//
//  BluetoothManager.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import CoreBluetooth
import SwiftUI

enum ConnectionState {
    case idle
    case scanning
    case connecting
    case connected
    case unauthorized
    case poweredOff
}

/// Bluetooth UUIDs used by the Fitness Machine Service (FTMS).
///
/// FTMS is a Bluetooth SIG–defined standard for gym equipment
/// such as bikes, treadmills, and rowers. Schwinn IC4 uses this
/// service to stream live workout metrics.
enum FTMSUUID {

    /// Fitness Machine Service
    ///
    /// UUID: 0x1826
    /// Primary service that identifies a device as FTMS-capable.
    /// Used during scanning and service discovery.
    static let service = CBUUID(string: Constants.Bluetooth.FTMSUUIDString.service)

    /// Indoor Bike Data
    ///
    /// UUID: 0x2AD2
    /// Streams cadence, power, speed, heart rate, etc.
    /// This characteristic is notify-only.
    static let indoorBikeData = CBUUID(string: Constants.Bluetooth.FTMSUUIDString.indoorBikeData)

    /// Fitness Machine Status
    ///
    /// UUID: 0x2ACC
    /// Indicates state changes such as started, stopped, paused.
    /// Optional; not all bikes populate this.
    static let machineStatus = CBUUID(string: Constants.Bluetooth.FTMSUUIDString.machineStatus)

    /// Fitness Machine Control Point
    ///
    /// UUID: 0x2AD9
    /// Used to control the machine (start, stop, set resistance).
    /// Requires explicit device support and permissions.
    static let controlPoint = CBUUID(string: Constants.Bluetooth.FTMSUUIDString.controlPoint)
}

final class BluetoothManager: NSObject, ObservableObject {
    @Published var state: ConnectionState = .idle
    @Published var metrics: BikeMetrics = BikeMetrics()
    
    private let parser = FTMSIndoorBikeParser()

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?

    override init() {
        super.init()
    }
    
    func activateAndConnect() {
        if central == nil {
            print(Constants.Bluetooth.Debug.activationPrompt)
            central = CBCentralManager(delegate: self, queue: .main)
        } else {
            startScanningOrReconnect()
        }
    }

    private func startScanningOrReconnect() {
        central?.scanForPeripherals(withServices: [FTMSUUID.service], options: nil)
    }
}

// MARK: - CBCentralManager Delegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            state = .scanning
            central.scanForPeripherals(withServices: [FTMSUUID.service], options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        state = .connecting

        central.stopScan()
        peripheral.delegate = self
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        state = .connected
        peripheral.discoverServices([FTMSUUID.service])
    }
}

// MARK: - CBPeripheral Delegate

extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            // You can limit this to FTMS only if you want.
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        service.characteristics?.forEach { characteristic in
            if characteristic.uuid == FTMSUUID.indoorBikeData {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard error == nil else { return }
        guard characteristic.uuid == FTMSUUID.indoorBikeData,
              let data = characteristic.value else { return }

        if let parsed = parser.parse(data) {
            metrics = parsed
        }
    }
}

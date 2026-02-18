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

struct DiscoveredPeripheral: Identifiable, Equatable {
    let id: UUID
    let name: String
    let rssi: Int
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
    static let service = CBUUID(string: Copy.bluetooth.ftmsUUIDString.service)

    /// Indoor Bike Data
    ///
    /// UUID: 0x2AD2
    /// Streams cadence, power, speed, heart rate, etc.
    /// This characteristic is notify-only.
    static let indoorBikeData = CBUUID(string: Copy.bluetooth.ftmsUUIDString.indoorBikeData)

    /// Fitness Machine Status
    ///
    /// UUID: 0x2ACC
    /// Indicates state changes such as started, stopped, paused.
    /// Optional; not all bikes populate this.
    static let machineStatus = CBUUID(string: Copy.bluetooth.ftmsUUIDString.machineStatus)

    /// Fitness Machine Control Point
    ///
    /// UUID: 0x2AD9
    /// Used to control the machine (start, stop, set resistance).
    /// Requires explicit device support and permissions.
    static let controlPoint = CBUUID(string: Copy.bluetooth.ftmsUUIDString.controlPoint)
}

final class BluetoothManager: NSObject, ObservableObject {
    @Published var state: ConnectionState = .idle
    @Published var metrics: BikeMetrics = BikeMetrics()
    @Published var discoveredPeripherals: [DiscoveredPeripheral] = []
    
    private let parser = FTMSIndoorBikeParser()

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var discoveredMap: [UUID: CBPeripheral] = [:]

    override init() {
        super.init()
    }
    
    func activateAndConnect() {
        if central == nil {
            // Initialize on main queue but operations happen on background
            central = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .userInitiated))
        } else {
            startScanningOrReconnect()
        }
    }

    private func startScanningOrReconnect() {
        DispatchQueue.main.async {
            self.discoveredPeripherals.removeAll()
        }
        discoveredMap.removeAll()
        DispatchQueue.main.async {
            self.state = .scanning
        }
        central?.scanForPeripherals(withServices: [FTMSUUID.service], options: nil)
    }

    func connect(to peripheralID: UUID) {
        guard let peripheral = discoveredMap[peripheralID] else { return }
        self.peripheral = peripheral
        DispatchQueue.main.async {
            self.state = .connecting
        }
        central.stopScan()
        peripheral.delegate = self
        central.connect(peripheral)
    }

    private func upsertDiscovered(peripheral: CBPeripheral, rssi: NSNumber) {
        let name = peripheral.name ?? Copy.bluetooth.unknownDevice
        let entry = DiscoveredPeripheral(
            id: peripheral.identifier,
            name: name,
            rssi: rssi.intValue
        )
        
        DispatchQueue.main.async {
            if let index = self.discoveredPeripherals.firstIndex(where: { $0.id == entry.id }) {
                self.discoveredPeripherals[index] = entry
            } else {
                self.discoveredPeripherals.append(entry)
            }
            self.discoveredPeripherals.sort { $0.rssi > $1.rssi }
        }
        
        discoveredMap[entry.id] = peripheral
    }
}

// MARK: - CBCentralManager Delegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            switch central.state {
            case .poweredOn:
                self.state = .scanning
                central.scanForPeripherals(withServices: [FTMSUUID.service], options: nil)
            case .unauthorized:
                self.state = .unauthorized
            case .poweredOff:
                self.state = .poweredOff
            default:
                self.state = .idle
            }
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        upsertDiscovered(peripheral: peripheral, rssi: RSSI)
    }

    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.state = .connected
        }
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
            DispatchQueue.main.async {
                self.metrics = parsed
            }
        }
    }
}

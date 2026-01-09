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

final class BluetoothManager: NSObject, ObservableObject {
    @Published var state: ConnectionState = .idle
//    @Published var metrics = BikeMetrics()

    private var central: CBCentralManager!
    private var peripheral: CBPeripheral?

    private let ftmsServiceUUID = CBUUID(string: "1826")
    private let indoorBikeDataUUID = CBUUID(string: "2AD2")

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: .main)
    }
}

// MARK: - CBCentralManager Delegate

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            state = .scanning
            central.scanForPeripherals(withServices: [ftmsServiceUUID], options: nil)
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
        peripheral.discoverServices([ftmsServiceUUID])
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
            if characteristic.uuid == indoorBikeDataUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    // Next step: receive notifications here
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard characteristic.uuid == indoorBikeDataUUID,
              let data = characteristic.value else { return }

        // NEXT STEP: parse bike data -> usable data
        let hex = data.map { String(format: "%02hhx", $0) }.joined(separator: " ")
        print("Indoor Bike Data:", hex)
    }
}

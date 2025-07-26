//
//  BLEManager.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import Foundation
import CoreBluetooth
import Combine

enum ConnectionState {
    case disconnected
    case scanning
    case connecting
    case connected
    case failedToConnect
    
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .scanning: return "Scanning..."
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .failedToConnect: return "Failed to Connect"
        }
    }
}

enum DoorState {
    case open
    case closed
    case unknown
}

class BLEManager: NSObject, ObservableObject {
    // CoreBluetooth properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    
    // Published properties for SwiftUI
    @Published var connectionState: ConnectionState = .disconnected
    @Published var doorState: DoorState = .unknown
    @Published var rssi: Int = 0
    @Published var availablePeripherals: [CBPeripheral] = []
    @Published var receivedMessages: [String] = []
    @Published var connectedDeviceName: String? = nil
    
    // HM-10 BLE module service and characteristic UUIDs
    // Serial service UUID for HM-10 is typically FF10
    private let serviceUUID = CBUUID(string: "FFE0")
    private let characteristicUUID = CBUUID(string: "FFE1")
    
    // Commands
    var openCommand = "open\n"
    var closeCommand = "close\n"
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    // Getter for peripheral name
    var peripheralName: String? {
        return peripheral?.name
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        
        connectionState = .scanning
        availablePeripherals.removeAll()
        
        // Start scanning for peripherals with the specific service UUID
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        
        // Stop scanning after 10 seconds if nothing found
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.connectionState == .scanning else { return }
            self.centralManager.stopScan()
            if self.availablePeripherals.isEmpty {
                self.connectionState = .disconnected
            }
        }
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        self.connectionState = .connecting
        self.centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func openDoor() {
        sendCommand(openCommand)
        doorState = .open
    }
    
    func closeDoor() {
        sendCommand(closeCommand)
        doorState = .closed
    }
    
    func sendCommand(_ command: String) {
        guard let peripheral = peripheral, 
              let characteristic = writeCharacteristic,
              connectionState == .connected else {
            print("Cannot send command: not connected")
            return
        }
        
        if let data = command.data(using: .utf8) {
            // Write with response to ensure delivery
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            connectionState = .disconnected
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unknown:
            print("Bluetooth is unknown")
        @unknown default:
            print("Unknown Bluetooth state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Filter for HM-10 devices or show all discovered devices
        let name = peripheral.name ?? "Unknown Device"
        if !availablePeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            print("Discovered: \(name) - RSSI: \(RSSI.intValue)")
            availablePeripherals.append(peripheral)
        }
        
        // Update RSSI if this is our connected peripheral
        if self.peripheral?.identifier == peripheral.identifier {
            self.rssi = RSSI.intValue
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        self.peripheral = peripheral
        self.connectedDeviceName = peripheral.name
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        self.connectionState = .connected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "Unknown error")")
        self.connectionState = .failedToConnect
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device"): \(error?.localizedDescription ?? "No error")")
        self.connectionState = .disconnected
        self.peripheral = nil
        self.writeCharacteristic = nil
        self.connectedDeviceName = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            print("Discovered service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic)")
            
            // Find a characteristic we can write to
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                self.writeCharacteristic = characteristic
                print("Found writable characteristic: \(characteristic)")
            }
            
            // Subscribe to notifications if the characteristic supports it
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to notifications for characteristic: \(characteristic)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving data: \(error.localizedDescription)")
            return
        }
        
        guard let data = characteristic.value, let message = String(data: data, encoding: .utf8) else {
            return
        }
        
        print("Received: \(message)")
        receivedMessages.append(message)
        
        // Update door state based on received message (if applicable)
        if message.contains("open") {
            self.doorState = .open
        } else if message.contains("closed") {
            self.doorState = .closed
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing data: \(error.localizedDescription)")
        } else {
            print("Data written successfully")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let error = error {
            print("Error reading RSSI: \(error.localizedDescription)")
            return
        }
        
        self.rssi = RSSI.intValue
    }
} 
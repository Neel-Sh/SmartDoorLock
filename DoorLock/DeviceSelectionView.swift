//
//  DeviceSelectionView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI
import CoreBluetooth

struct DeviceSelectionView: View {
    @ObservedObject var bleManager: BLEManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                if bleManager.availablePeripherals.isEmpty && bleManager.connectionState == .scanning {
                    VStack(spacing: 16) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("Scanning for Devices...")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Please make sure your BLE device is powered on and nearby.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if bleManager.availablePeripherals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bluetooth.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Devices Found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Tap 'Scan' to search for nearby BLE devices.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(bleManager.availablePeripherals, id: \.identifier) { peripheral in
                            Button(action: {
                                connectToDevice(peripheral)
                            }) {
                                HStack {
                                    Image(systemName: "wave.3.right")
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(peripheral.name ?? "Unknown Device")
                                            .font(.headline)
                                        Text(peripheral.identifier.uuidString)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(bleManager.connectionState == .scanning ? "Scanning..." : "Scan") {
                        bleManager.startScanning()
                    }
                    .disabled(bleManager.connectionState == .scanning)
                }
            }
        }
    }
    
    private func connectToDevice(_ peripheral: CBPeripheral) {
        bleManager.connectToPeripheral(peripheral)
        isPresented = false
    }
}

#Preview {
    // Creating a mock BLEManager for preview
    let bleManager = BLEManager()
    return DeviceSelectionView(bleManager: bleManager, isPresented: .constant(true))
} 
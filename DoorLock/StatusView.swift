//
//  StatusView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct StatusView: View {
    var connectionState: ConnectionState
    var rssi: Int
    var deviceName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Connection status with animation
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(connectionStateColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: connectionStateIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(connectionStateColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(connectionState.description)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(connectionStateColor)
                    
                    if let deviceName = deviceName, !deviceName.isEmpty, connectionState == .connected {
                        Text("Connected to \(deviceName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if connectionState == .connected {
                    VStack(alignment: .trailing, spacing: 6) {
                        SignalStrengthView(rssi: rssi)
                        
                        Text("Signal Strength")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.trailing, 4)
                    }
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var connectionStateIcon: String {
        switch connectionState {
        case .disconnected:
            return "bluetooth.slash"
        case .scanning:
            return "arrow.clockwise"
        case .connecting:
            return "arrow.up.arrow.down"
        case .connected:
            return "bluetooth"
        case .failedToConnect:
            return "exclamationmark.circle"
        }
    }
    
    private var connectionStateColor: Color {
        switch connectionState {
        case .disconnected:
            return .gray
        case .scanning, .connecting:
            return .orange
        case .connected:
            return .green
        case .failedToConnect:
            return .red
        }
    }
}

struct SignalStrengthView: View {
    var rssi: Int
    
    // RSSI usually ranges from about -30 (very strong) to -100 (very weak)
    var signalStrength: Double {
        let clamped = min(max(Double(rssi), -100), -30)
        return (clamped + 100) / 70 // Normalize to 0-1 range
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(signalBarColor(for: index))
                    .frame(width: 3, height: 5 + Double(index) * 3)
            }
            
            Text("\(rssi) dBm")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
    }
    
    private func signalBarColor(for index: Int) -> Color {
        let threshold = Double(index) / 4.0
        if signalStrength >= threshold {
            if signalStrength > 0.7 {
                return .green
            } else if signalStrength > 0.4 {
                return .orange
            } else {
                return .red
            }
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusView(connectionState: .disconnected, rssi: 0)
        StatusView(connectionState: .scanning, rssi: 0)
        StatusView(connectionState: .connecting, rssi: 0)
        StatusView(connectionState: .connected, rssi: -65, deviceName: "HM-10 Door Lock")
        StatusView(connectionState: .failedToConnect, rssi: 0)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 
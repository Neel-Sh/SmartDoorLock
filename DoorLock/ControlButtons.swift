//
//  ControlButtons.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct ControlButtons: View {
    var connectionState: ConnectionState
    var doorState: DoorState
    var onScan: () -> Void
    var onDisconnect: () -> Void
    var onOpenDoor: () -> Void
    var onCloseDoor: () -> Void
    
    // For press animation
    @State private var isPressedOpen = false
    @State private var isPressedClose = false
    @State private var isPressedConnection = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title
            Text("DOOR CONTROLS")
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            
            VStack(spacing: 12) {
                // Primary action buttons (unlock/lock)
                PrimaryActionButton(
                    title: "UNLOCK DOOR",
                    icon: "lock.open.fill",
                    color: .green,
                    isActive: connectionState == .connected && doorState != .open,
                    isPressed: $isPressedOpen,
                    action: {
                        playHaptic(.medium)
                        onOpenDoor()
                    }
                )
                
                PrimaryActionButton(
                    title: "LOCK DOOR",
                    icon: "lock.fill",
                    color: .blue,
                    isActive: connectionState == .connected && doorState != .closed,
                    isPressed: $isPressedClose,
                    action: {
                        playHaptic(.medium)
                        onCloseDoor()
                    }
                )
                
                Divider()
                    .padding(.vertical, 8)
                
                // Connection button
                if connectionState == .disconnected || connectionState == .failedToConnect {
                    SecondaryActionButton(
                        title: "SCAN FOR DEVICES",
                        icon: "antenna.radiowaves.left.and.right",
                        isActive: connectionState != .scanning,
                        isPressed: $isPressedConnection,
                        action: {
                            playHaptic(.light)
                            onScan()
                        }
                    )
                } else {
                    SecondaryActionButton(
                        title: "DISCONNECT",
                        icon: "bluetooth.slash",
                        isActive: true,
                        isPressed: $isPressedConnection,
                        action: {
                            playHaptic(.light)
                            onDisconnect()
                        }
                    )
                }
            }
        }
    }
    
    private func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct PrimaryActionButton: View {
    var title: String
    var icon: String
    var color: Color
    var isActive: Bool
    @Binding var isPressed: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if isActive {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                    action()
                }
            }
        }) {
            HStack(spacing: 16) {
                // Icon in circle
                ZStack {
                    Circle()
                        .fill(isActive ? color.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isActive ? color : Color.gray.opacity(0.5))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .tracking(0.5)
                    .foregroundColor(isActive ? .primary : .secondary.opacity(0.7))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isActive ? color.opacity(0.8) : Color.gray.opacity(0.3))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.tertiarySystemBackground).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isActive ? color.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: isActive ? color.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isActive)
    }
}

struct SecondaryActionButton: View {
    var title: String
    var icon: String
    var isActive: Bool
    @Binding var isPressed: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            if isActive {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                    action()
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isActive ? .primary.opacity(0.8) : .secondary.opacity(0.6))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(isActive ? .primary.opacity(0.8) : .secondary.opacity(0.6))
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.tertiarySystemBackground).opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isActive)
    }
}

#Preview {
    VStack(spacing: 30) {
        ControlButtons(
            connectionState: .connected,
            doorState: .closed,
            onScan: {},
            onDisconnect: {},
            onOpenDoor: {},
            onCloseDoor: {}
        )
        
        ControlButtons(
            connectionState: .disconnected, 
            doorState: .unknown,
            onScan: {},
            onDisconnect: {},
            onOpenDoor: {},
            onCloseDoor: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
} 
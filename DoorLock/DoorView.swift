//
//  DoorView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct DoorView: View {
    var doorState: DoorState
    
    @State private var animationInProgress = false
    @State private var previousDoorState: DoorState = .unknown
    @State private var glowOpacity: Double = 0
    @State private var indicatorScale: CGFloat = 0.95
    
    var body: some View {
        // This view is no longer used directly in the main UI
        // It has been replaced by CompactLockView in ContentView.swift
        // This is kept for compatibility with existing code
        
        VStack(spacing: 16) {
            // Smart Lock Visualization
            ZStack {
                // Background with subtle gradient
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(UIColor.systemBackground),
                                Color(UIColor.systemBackground).opacity(0.9)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 240)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 24) {
                    // Status indicator circle with glow
                    ZStack {
                        // Outer circle
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        statusColor.opacity(0.3),
                                        statusColor.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 8
                            )
                            .frame(width: 120, height: 120)
                        
                        // Animated glow
                        Circle()
                            .fill(statusColor)
                            .frame(width: 100, height: 100)
                            .blur(radius: 30)
                            .opacity(glowOpacity * 0.3)
                        
                        // Inner circle with status color
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        statusColor,
                                        statusColor.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .scaleEffect(indicatorScale)
                            .shadow(color: statusColor.opacity(0.5), radius: 8, x: 0, y: 2)
                        
                        // Status icon
                        Image(systemName: doorState == .open ? "lock.open.fill" : "lock.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Status text
                    Text(statusText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(statusColor)
                }
            }
            
            // Access information card
            HStack(spacing: 25) {
                // Last accessed info
                VStack(alignment: .leading, spacing: 4) {
                    Text("LAST ACCESS")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .tracking(1)
                    
                    Text(getCurrentTimeString())
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Access status
                VStack(alignment: .leading, spacing: 4) {
                    Text("STATUS")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                        .tracking(1)
                    
                    Text(doorState == .open ? "UNLOCKED" : "SECURED")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(doorState == .open ? .green : .blue)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.horizontal)
        .onChange(of: doorState) { _ in
            if previousDoorState != doorState {
                animateStatusChange()
                previousDoorState = doorState
            }
        }
        .onAppear {
            // Initialize status
            previousDoorState = doorState
            
            // Start breathing animation
            startBreathingAnimation()
        }
    }
    
    private var statusColor: Color {
        switch doorState {
        case .open:
            return .green
        case .closed:
            return .blue
        case .unknown:
            return .gray
        }
    }
    
    private var statusText: String {
        switch doorState {
        case .open:
            return "Door Unlocked"
        case .closed:
            return "Door Secured"
        case .unknown:
            return "Status Unknown"
        }
    }
    
    private func animateStatusChange() {
        // Pulse animation
        withAnimation(.easeInOut(duration: 0.3)) {
            glowOpacity = 0.9
            indicatorScale = 1.1
        }
        
        // Reset animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.3)) {
                indicatorScale = 0.95
            }
            
            // Start breathing animation
            startBreathingAnimation()
        }
    }
    
    private func startBreathingAnimation() {
        // Subtle breathing effect for the indicator
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = doorState == .open ? 0.8 : 0.4
            indicatorScale = 1.0
        }
    }
    
    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

#Preview {
    VStack(spacing: 30) {
        DoorView(doorState: .closed)
        DoorView(doorState: .open)
    }
} 
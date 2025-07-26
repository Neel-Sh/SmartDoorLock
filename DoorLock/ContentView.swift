//
//  ContentView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    
    @State private var showDeviceSelection = false
    @State private var selectedTab = 0
    
    // For visual effects
    @Environment(\.colorScheme) private var colorScheme
    
    // Custom accent color for app-wide use
    private let accentColor = Color(red: 0.0, green: 0.48, blue: 0.98)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab (Main Controls)
            HomeView(bleManager: bleManager, showDeviceSelection: $showDeviceSelection)
                .tabItem {
                    Image(systemName: "lock.shield")
                    Text("Control")
                }
                .tag(0)
            
            // Logs Tab
            LogsView(bleManager: bleManager)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Activity")
                }
                .tag(1)
            
            // Settings Tab
            SettingsTabView(bleManager: bleManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .tint(accentColor) // Using .tint instead of .accentColor for iOS 16+
        .sheet(isPresented: $showDeviceSelection) {
            DeviceSelectionView(bleManager: bleManager, isPresented: $showDeviceSelection)
        }
        .onAppear {
            // Apply accent color to global UI elements
            UITabBar.appearance().tintColor = UIColor(accentColor)
            
            // Check if we should auto-connect
            checkAutoConnect()
        }
    }
    
    private func checkAutoConnect() {
        // Placeholder for auto-connect functionality
        // In a full implementation, would retrieve the saved device ID and attempt reconnection
    }
}

// Home Tab View with main controls
struct HomeView: View {
    @ObservedObject var bleManager: BLEManager
    @Binding var showDeviceSelection: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemGroupedBackground),
                        colorScheme == .dark ? 
                            Color(UIColor.systemGroupedBackground) : 
                            Color(UIColor.systemGroupedBackground).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Main content
                ScrollView {
                    VStack(spacing: 28) {
                        // Status Card with shadow and elevation
                        StatusCard(bleManager: bleManager)
                            .padding(.bottom, 4)
                        
                        // Lock visualization and controls in a single elevated card
                        VStack(spacing: 0) {
                            // Lock Visualization (Compact version)
                            CompactLockView(doorState: bleManager.doorState)
                                .frame(height: 145)
                                .padding(.vertical, 12)
                                
                            Divider()
                                .padding(.horizontal)
                            
                            // Primary controls with refined buttons
                            PrimaryControlsView(
                                connectionState: bleManager.connectionState,
                                doorState: bleManager.doorState,
                                onOpenDoor: { withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { bleManager.openDoor() }},
                                onCloseDoor: { withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) { bleManager.closeDoor() }}
                            )
                            .padding(.vertical, 20)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 5)
                        )
                        
                        // Connection status or device info with refined styling
                        if bleManager.connectionState == .connected {
                            ConnectionInfoCard(bleManager: bleManager, onDisconnect: { bleManager.disconnect() })
                        } else {
                            // Get started card for non-connected state
                            GetStartedCard(
                                connectionState: bleManager.connectionState,
                                onScan: { showDeviceSelection = true }
                            )
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("Smart Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDeviceSelection = true }) {
                        ZStack {
                            Circle()
                                .fill(bleManager.connectionState == .connected ? Color.green.opacity(0.15) : Color.clear)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(bleManager.connectionState == .connected ? .green : .primary)
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                        
                        Text("SMART LOCK")
                            .font(.system(size: 14, weight: .semibold))
                            .tracking(0.6)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// Primary control buttons only (without connection controls)
struct PrimaryControlsView: View {
    var connectionState: ConnectionState
    var doorState: DoorState
    var onOpenDoor: () -> Void
    var onCloseDoor: () -> Void
    
    @State private var isPressedOpen = false
    @State private var isPressedClose = false
    
    var body: some View {
        VStack(spacing: 18) {
            // Primary action buttons (unlock/lock) in horizontal layout
            HStack(spacing: 12) {
                // Unlock button with enhanced design
                Button(action: {
                    playHaptic(.medium)
                    onOpenDoor()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Text("UNLOCK")
                            .font(.system(size: 15, weight: .semibold))
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .contentShape(Rectangle())
                }
                .background(
                    ZStack {
                        // Base gradient
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.27, green: 0.82, blue: 0.46).opacity(doorState != .open && connectionState == .connected ? 1.0 : 0.4),
                                        Color(red: 0.22, green: 0.68, blue: 0.38).opacity(doorState != .open && connectionState == .connected ? 1.0 : 0.4)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Subtle inner shadow
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .foregroundColor(.white)
                .shadow(color: Color(red: 0.27, green: 0.82, blue: 0.46).opacity(doorState != .open && connectionState == .connected ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
                .disabled(doorState == .open || connectionState != .connected)
                .scaleEffect(isPressedOpen ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressedOpen)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    isPressedOpen = pressing
                }, perform: {})
                
                // Lock button with enhanced design
                Button(action: {
                    playHaptic(.medium)
                    onCloseDoor()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Text("LOCK")
                            .font(.system(size: 15, weight: .semibold))
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .contentShape(Rectangle())
                }
                .background(
                    ZStack {
                        // Base gradient
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.48, blue: 0.98).opacity(doorState != .closed && connectionState == .connected ? 1.0 : 0.4),
                                        Color(red: 0.0, green: 0.4, blue: 0.85).opacity(doorState != .closed && connectionState == .connected ? 1.0 : 0.4)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Subtle inner shadow
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .foregroundColor(.white)
                .shadow(color: Color(red: 0.0, green: 0.48, blue: 0.98).opacity(doorState != .closed && connectionState == .connected ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
                .disabled(doorState == .closed || connectionState != .connected)
                .scaleEffect(isPressedClose ? 0.97 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressedClose)
                .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
                    isPressedClose = pressing
                }, perform: {})
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Additional connection info card
struct ConnectionInfoCard: View {
    @ObservedObject var bleManager: BLEManager
    var onDisconnect: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isPressedDisconnect = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with refined typography
            HStack {
                Text("DEVICE INFORMATION")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color.secondary.opacity(0.85))
                
                Spacer()
                
                // Disconnect button with refined styling
                Button(action: onDisconnect) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                        
                        Text("DISCONNECT")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.5)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.15))
                    )
                    .foregroundColor(.red)
                }
            }
            
            // Device info with refined layout
            if let deviceName = bleManager.peripheralName {
                VStack(spacing: 12) {
                    // Device name
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "wave.3.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deviceName)
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Bluetooth Device")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Signal strength indicator with refined design
                        HStack(spacing: 4) {
                            ForEach(0..<signalBars, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.green)
                                    .frame(width: 3, height: 10 + CGFloat(0) * 2)
                            }
                            
                            ForEach(0..<(5-signalBars), id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1.5)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 3, height: 10 + CGFloat(0 + signalBars) * 2)
                            }
                        }
                        .padding(.horizontal, 6)
                    }
                    
                    Divider()
                        .padding(.horizontal, 6)
                    
                    // Connection time with refined styling
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.15))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Connection Time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Text(formattedConnectionTime)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
    }
    
    private var signalBars: Int {
        // Calculate signal strength bars (1-5) based on RSSI
        // RSSI typically ranges from -30 (very strong) to -100 (very weak)
        let clamped = min(max(Double(bleManager.rssi), -100), -30)
        let normalized = (clamped + 100) / 70 // 0 to 1
        return max(1, min(5, Int(normalized * 5)))
    }
    
    private var formattedConnectionTime: String {
        // This would typically use actual connection time
        // For now, just return a placeholder
        return "Connected for 10 minutes"
    }
}

// Logs Tab View
struct LogsView: View {
    @ObservedObject var bleManager: BLEManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with subtle gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemGroupedBackground),
                        colorScheme == .dark ? 
                            Color(UIColor.systemGroupedBackground) : 
                            Color(UIColor.systemGroupedBackground).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if bleManager.receivedMessages.isEmpty {
                    // Empty state with refined visuals
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.secondary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.secondary.opacity(0.7))
                        }
                        
                        Text("No Activity Logs")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("Activity logs will appear here when you operate the lock")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // Logs list with refined styling
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("RECENT ACTIVITY")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(1.2)
                                .foregroundStyle(Color.secondary.opacity(0.85))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            
                            Spacer()
                        }
                        
                        ScrollView {
                            LazyVStack(spacing: 2) {
                                ForEach(bleManager.receivedMessages.indices.reversed(), id: \.self) { index in
                                    LogEntryView(message: bleManager.receivedMessages[index], index: index)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(UIColor.secondarySystemBackground))
                                                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Activity Logs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LogEntryView: View {
    var message: String
    var index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Activity icon
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activityIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(activityColor)
            }
            
            // Message content
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedMessage)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                    
                    Text(formattedTime(index))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                    
                    Spacer()
                    
                    // Device indicator
                    Text("HM-10")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                        .foregroundColor(Color.blue)
                }
            }
        }
    }
    
    // Determine icon and color based on message content
    private var activityIcon: String {
        if message.contains("open") {
            return "lock.open.fill"
        } else if message.contains("close") {
            return "lock.fill"
        } else {
            return "text.bubble.fill"
        }
    }
    
    private var activityColor: Color {
        if message.contains("open") {
            return Color(red: 0.27, green: 0.82, blue: 0.46) // Green
        } else if message.contains("close") {
            return Color(red: 0.0, green: 0.48, blue: 0.98) // Blue
        } else {
            return Color.orange
        }
    }
    
    // Format message for display
    private var formattedMessage: String {
        if message.contains("open") {
            return "Door unlocked"
        } else if message.contains("close") {
            return "Door locked"
        } else {
            return message
        }
    }
    
    private func formattedTime(_ index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = Date().addingTimeInterval(-Double((index) * 30))
        return dateFormatter.string(from: date)
    }
}

// Settings Tab View
struct SettingsTabView: View {
    @ObservedObject var bleManager: BLEManager
    @State private var showCommandView = false
    
    @AppStorage("openCommand") private var openCommand = "open\n"
    @AppStorage("closeCommand") private var closeCommand = "close\n"
    @AppStorage("autoConnect") private var autoConnect = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("CONNECTION")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(bleManager.connectionState.description)
                            .foregroundColor(connectionStatusColor)
                    }
                    
                    if let name = bleManager.peripheralName, bleManager.connectionState == .connected {
                        HStack {
                            Text("Connected Device")
                            Spacer()
                            Text(name)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle("Auto-connect on launch", isOn: $autoConnect)
                }
                
                Section(header: Text("COMMANDS")) {
                    Button(action: { showCommandView = true }) {
                        Text("Send Custom Command")
                    }
                    
                    NavigationLink(destination: CommandSettingsView(bleManager: bleManager)) {
                        Text("Edit Default Commands")
                    }
                }
                
                Section(header: Text("ABOUT")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Bluetooth Library")
                        Spacer()
                        Text("CoreBluetooth")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCommandView) {
                CustomCommandView(isPresented: $showCommandView, bleManager: bleManager)
            }
        }
    }
    
    private var connectionStatusColor: Color {
        switch bleManager.connectionState {
        case .connected: return .green
        case .disconnected: return .gray
        case .connecting, .scanning: return .orange
        case .failedToConnect: return .red
        }
    }
}

// Commands Settings View
struct CommandSettingsView: View {
    @ObservedObject var bleManager: BLEManager
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("openCommand") private var openCommand = "open\n"
    @AppStorage("closeCommand") private var closeCommand = "close\n"
    
    @State private var tempOpenCommand: String = ""
    @State private var tempCloseCommand: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("DEFAULT COMMANDS")) {
                VStack(alignment: .leading) {
                    Text("Open Command")
                        .font(.headline)
                    
                    TextField("Command", text: $tempOpenCommand)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                .padding(.vertical, 6)
                
                VStack(alignment: .leading) {
                    Text("Close Command")
                        .font(.headline)
                    
                    TextField("Command", text: $tempCloseCommand)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Command Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveCommands()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .onAppear {
            tempOpenCommand = stripNewline(openCommand)
            tempCloseCommand = stripNewline(closeCommand)
        }
    }
    
    private func saveCommands() {
        openCommand = ensureNewline(tempOpenCommand)
        closeCommand = ensureNewline(tempCloseCommand)
        
        bleManager.openCommand = openCommand
        bleManager.closeCommand = closeCommand
    }
    
    private func ensureNewline(_ command: String) -> String {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasSuffix("\n") ? trimmed : "\(trimmed)\n"
    }
    
    private func stripNewline(_ command: String) -> String {
        return command.hasSuffix("\n") ? String(command.dropLast()) : command
    }
}

// Custom Components

struct StatusCard: View {
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Connection status icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 46, height: 46)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(statusColor)
            }
            
            // Status info
            VStack(alignment: .leading, spacing: 4) {
                Text(statusTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)
                
                Text(statusDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary.opacity(0.9))
            }
            
            Spacer()
            
            // Signal strength if connected
            if bleManager.connectionState == .connected {
                SignalStrengthView(rssi: bleManager.rssi)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
    
    private var statusColor: Color {
        switch bleManager.connectionState {
        case .connected: return Color(red: 0.27, green: 0.82, blue: 0.46) // More Apple-like green
        case .disconnected: return Color.gray
        case .connecting, .scanning: return Color(red: 1.0, green: 0.65, blue: 0.07) // Warmer orange
        case .failedToConnect: return Color(red: 0.98, green: 0.26, blue: 0.27) // Refined red
        }
    }
    
    private var statusIcon: String {
        switch bleManager.connectionState {
        case .connected: return "bluetooth"
        case .disconnected: return "bluetooth.slash"
        case .connecting: return "arrow.up.arrow.down"
        case .scanning: return "arrow.clockwise"
        case .failedToConnect: return "exclamationmark.circle"
        }
    }
    
    private var statusTitle: String {
        switch bleManager.connectionState {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .scanning: return "Scanning"
        case .failedToConnect: return "Connection Failed"
        }
    }
    
    private var statusDescription: String {
        if case .connected = bleManager.connectionState, let name = bleManager.peripheralName {
            return name
        }
        
        switch bleManager.connectionState {
        case .connected: return "Lock is connected and ready"
        case .disconnected: return "No lock connected"
        case .connecting: return "Establishing connection"
        case .scanning: return "Looking for devices"
        case .failedToConnect: return "Please try again"
        }
    }
}

struct CompactLockView: View {
    var doorState: DoorState
    
    @State private var glowOpacity: Double = 0
    @State private var indicatorScale: CGFloat = 0.96
    @State private var rotationDegrees: Double = 0
    
    var body: some View {
        HStack(spacing: 20) {
            // Lock indicator
            ZStack {
                // Animated glow
                Circle()
                    .fill(statusColor)
                    .frame(width: 85, height: 85)
                    .blur(radius: 20)
                    .opacity(glowOpacity * 0.35)
                
                // Lock circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                statusColor.opacity(0.95),
                                statusColor.opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: 66, height: 66)
                    .scaleEffect(indicatorScale)
                    .shadow(color: statusColor.opacity(0.6), radius: 8, x: 0, y: 3)
                
                // Lock icon with rotation animation
                Image(systemName: doorState == .open ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationDegrees))
            }
            .frame(width: 95, height: 95)
            
            // Status and info
            VStack(alignment: .leading, spacing: 15) {
                // Status text
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusText)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundColor(statusColor)
                    
                    Text(doorState == .open ? "Door is unlocked and accessible" : "Door is locked and secured")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.secondary.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Last access time with refined styling
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary.opacity(0.75))
                    
                    Text("Last activity: \(getCurrentTimeString())")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary.opacity(0.75))
                }
                .padding(.top, 2)
            }
            .padding(.trailing)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 22)
        .onAppear {
            startAnimations()
        }
        .onChange(of: doorState) { _ in
            animateLockChange()
        }
    }
    
    private var statusColor: Color {
        switch doorState {
        case .open: return Color(red: 0.27, green: 0.82, blue: 0.46) // More refined green
        case .closed: return Color(red: 0.0, green: 0.48, blue: 0.98) // Rich blue
        case .unknown: return Color.gray
        }
    }
    
    private var statusText: String {
        switch doorState {
        case .open: return "Unlocked"
        case .closed: return "Locked"
        case .unknown: return "Unknown"
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            glowOpacity = doorState == .open ? 0.9 : 0.5
            indicatorScale = 1.0
        }
    }
    
    private func animateLockChange() {
        // Create a rotation animation when lock state changes
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            rotationDegrees = doorState == .open ? 20 : 0
        }
        
        // Reset and restart breathing animation
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            glowOpacity = doorState == .open ? 0.9 : 0.5
        }
    }
    
    private func getCurrentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
}

// Get Started Card for disconnected state
struct GetStartedCard: View {
    var connectionState: ConnectionState
    var onScan: () -> Void
    
    var body: some View {
        VStack(spacing: 22) {
            // Icon and title
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Text("Connect to Your Lock")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Instructions with typography refinements
            Text("To control your door lock, you need to connect to a compatible Bluetooth device.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary.opacity(0.9))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
            
            // Connect button with refined styling
            Button(action: onScan) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("SCAN FOR DEVICES")
                        .font(.system(size: 14, weight: .semibold))
                        .tracking(0.5)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .contentShape(Rectangle())
            }
            .background(
                ZStack {
                    // Base gradient
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.9)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Subtle inner shadow
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .foregroundColor(.white)
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 30)
            .padding(.top, 10)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
    }
}

#Preview {
    ContentView()
}

//
//  SettingsView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @ObservedObject var bleManager: BLEManager
    
    @AppStorage("openCommand") private var openCommand = "open\n"
    @AppStorage("closeCommand") private var closeCommand = "close\n"
    @AppStorage("autoConnect") private var autoConnect = false
    @AppStorage("lastConnectedDeviceID") private var lastConnectedDeviceID = ""
    
    @State private var tempOpenCommand: String = ""
    @State private var tempCloseCommand: String = ""
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Commands")) {
                    VStack(alignment: .leading) {
                        Text("Open Command")
                            .font(.headline)
                        
                        TextField("Command", text: $tempOpenCommand)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        
                        Text("Will automatically append \\n if not present")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                        
                        Text("Will automatically append \\n if not present")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                
                Section(header: Text("Connection")) {
                    Toggle("Auto-connect to last device", isOn: $autoConnect)
                    
                    if !lastConnectedDeviceID.isEmpty {
                        HStack {
                            Text("Last Connected Device:")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text(formatDeviceID(lastConnectedDeviceID))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        Text("Reset to Defaults")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        isPresented = false
                    }
                }
            }
            .onAppear {
                tempOpenCommand = stripNewline(openCommand)
                tempCloseCommand = stripNewline(closeCommand)
            }
            .alert("Reset Settings", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetToDefaults()
                }
            } message: {
                Text("This will reset all settings to their default values.")
            }
        }
    }
    
    private func saveSettings() {
        // Ensure commands end with newline
        openCommand = ensureNewline(tempOpenCommand)
        closeCommand = ensureNewline(tempCloseCommand)
        
        // Update the BLEManager
        bleManager.openCommand = openCommand
        bleManager.closeCommand = closeCommand
    }
    
    private func resetToDefaults() {
        tempOpenCommand = "open"
        tempCloseCommand = "close"
        autoConnect = false
        lastConnectedDeviceID = ""
        
        // Save the defaults
        saveSettings()
    }
    
    private func ensureNewline(_ command: String) -> String {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasSuffix("\n") ? trimmed : "\(trimmed)\n"
    }
    
    private func stripNewline(_ command: String) -> String {
        return command.hasSuffix("\n") ? String(command.dropLast()) : command
    }
    
    private func formatDeviceID(_ id: String) -> String {
        if id.count > 13 {
            return id.prefix(5) + "..." + id.suffix(5)
        }
        return id
    }
}

#Preview {
    SettingsView(isPresented: .constant(true), bleManager: BLEManager())
} 
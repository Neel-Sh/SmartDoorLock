//
//  CustomCommandView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct CustomCommandView: View {
    @Binding var isPresented: Bool
    @ObservedObject var bleManager: BLEManager
    
    @State private var commandText = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Command input field
                TextField("Enter command", text: $commandText)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                // Helper text
                Text("Enter the command without line endings. The app will automatically append a newline character (\\n) when sending.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Quick command suggestions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Commands")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickCommands, id: \.self) { command in
                                Button(action: {
                                    commandText = command
                                }) {
                                    Text(command)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                
                Spacer()
                
                // Send button
                Button(action: sendCommand) {
                    Text("Send Command")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(commandText.isEmpty || bleManager.connectionState != .connected ? Color.blue.opacity(0.3) : Color.blue)
                        )
                }
                .disabled(commandText.isEmpty || bleManager.connectionState != .connected)
            }
            .padding()
            .navigationTitle("Custom Command")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Command Sent", isPresented: $showSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Command '\(commandText)\\n' was sent to the device.")
            }
        }
    }
    
    private func sendCommand() {
        guard !commandText.isEmpty else { return }
        
        // Add newline character if needed
        var finalCommand = commandText
        if !finalCommand.hasSuffix("\n") {
            finalCommand += "\n"
        }
        
        // Send the command
        bleManager.sendCommand(finalCommand)
        
        // Show success alert
        showSuccessAlert = true
    }
    
    // Some predefined quick commands
    private let quickCommands = ["status", "open", "close", "lock", "unlock", "version", "help"]
}

#Preview {
    CustomCommandView(isPresented: .constant(true), bleManager: BLEManager())
} 
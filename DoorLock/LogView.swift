//
//  LogView.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

struct LogView: View {
    var messages: [String]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                if messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No Messages")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Messages from your device will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(messages.indices.reversed(), id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(messages[index])
                                    .font(.body)
                                    .padding(.vertical, 2)
                                
                                Text(formattedDate(index))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Message Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // This is a placeholder for timestamps - in a real app you'd store actual timestamps with the messages
    private func formattedDate(_ index: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        // Creating a fake timestamp based on index (newer messages are at higher indices)
        let date = Date().addingTimeInterval(-Double((messages.count - 1 - index) * 30))
        return dateFormatter.string(from: date)
    }
}

#Preview {
    LogView(
        messages: [
            "Door is now open",
            "Door is now closed",
            "Battery level: 85%",
            "Connection established"
        ],
        isPresented: .constant(true)
    )
} 
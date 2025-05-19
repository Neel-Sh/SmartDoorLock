//
//  DoorLockApp.swift
//  DoorLock
//
//  Created by Neel Sharma on 5/19/25.
//

import SwiftUI

@main
struct DoorLockApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

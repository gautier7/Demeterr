//
//  DemeterrApp.swift
//  Demeterr
//
//  Created by Gautier Colson on 20/11/25.
//

import SwiftUI
import SwiftData

@main
struct DemeterrApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DailyEntry.self,
            CustomFood.self,
            DailyGoals.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

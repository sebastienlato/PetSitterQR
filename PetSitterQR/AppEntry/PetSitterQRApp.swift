//
//  PetSitterQRApp.swift
//  PetSitterQR
//
//  Created by sebastien lato on 2025-11-16.
//

import SwiftData
import SwiftUI

@main
struct PetSitterQRApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: PersistedPet.self)
        } catch {
            fatalError("Unable to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(modelContext: modelContainer.mainContext)
        }
    }
}

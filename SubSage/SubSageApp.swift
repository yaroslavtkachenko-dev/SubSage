//
//  SubSageApp.swift
//  SubSage
//
//  Created by Yaroslav Tkachenko on 05.07.2025.
//

import SwiftUI

@main
struct SubSageApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

//
//  swiftUiDemoApp.swift
//  swiftUiDemo
//
//  Created by Mohamed Abd Elhakam on 11/12/2023.
//

import SwiftUI

@main
struct swiftUiDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AsyncLetBootcamp()

        }
    }
}

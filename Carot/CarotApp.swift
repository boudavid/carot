//
//  CarotApp.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI

@main
struct CarotApp: App {
    var body: some Scene {
        WindowGroup {
            GamesList(model: .init(date: Date.now))
        }
    }
}

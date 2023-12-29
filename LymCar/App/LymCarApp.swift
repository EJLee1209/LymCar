//
//  LymCarApp.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI

@main
struct LymCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appData: AppData = .init(
        authManager: AuthManager(),
        carPoolManager: CarPoolManager(),
        locationSearchManager: LocationSearchManager()
    )
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appData)
        }
    }
}



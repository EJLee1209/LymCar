//
//  LymCarApp.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI

@main
struct LymCarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appData: AppData = .init(
        authManager: AuthManager(),
        carPoolManager: CarPoolManager(),
        locationSearchManager: LocationSearchManager(),
        messageManager: MessageManager()
    )
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appData)
                .environmentObject(appDelegate)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
    }
}

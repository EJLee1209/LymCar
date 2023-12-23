//
//  RootViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

final class RootViewModel: ObservableObject {
    @Published var currentUser: User?
    
    private let authManager: AuthManagerType
    
    init(authManager: AuthManagerType) {
        self.authManager = authManager
    }
    
    func checkCurrentUser() async -> User? {
        let currentUser = await authManager.checkCurrentUser()
        
        await MainActor.run {
            self.currentUser = currentUser
        }
        
        return currentUser
    }
    
    func logout() {
        authManager.logout()
    }
}

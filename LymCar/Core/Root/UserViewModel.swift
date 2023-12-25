//
//  UserViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation
import Firebase

final class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var carPool: CarPool?
    
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

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
    
    func checkUserAndFetchUserCarPool() async -> User? {
        let currentUser = await AuthManager.shared.checkCurrentUser()
        fetchUserCarPool()
        
        await MainActor.run {
            self.currentUser = currentUser
            self.carPool = carPool
        }
        
        return currentUser
    }
    
    func fetchUserCarPool() {
        Task {
            let carPool = await CarPoolManager.shared.fetchMyCarPool()
            
            await MainActor.run {
                self.carPool = carPool
            }
        }
    }
    
    func logout() {
        AuthManager.shared.logout()
        currentUser = nil
        carPool = nil
    }
}

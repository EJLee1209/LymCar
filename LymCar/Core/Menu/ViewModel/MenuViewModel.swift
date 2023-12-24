//
//  MenuViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

final class MenuViewModel: ObservableObject {
    
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func logout() {
        let result = authManager.logout()
    }
    
}

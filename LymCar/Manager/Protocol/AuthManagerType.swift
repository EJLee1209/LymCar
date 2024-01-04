//
//  AuthManagerType.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import Foundation

protocol AuthManagerType {
    func createUser(
        withEmail email: String,
        password: String,
        gender: Gender,
        name: String
    ) async -> FirebaseNetworkResult<User>
    
    func signIn(
        withEmail email: String,
        password: String
    ) async -> FirebaseNetworkResult<User>
    
    func checkCurrentUser() async -> User?
    
    @discardableResult
    func logout() -> Bool
    
    func updateFcmToken(_ token: String) async
}

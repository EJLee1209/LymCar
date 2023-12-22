//
//  AuthManager.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation
import FirebaseAuth

protocol AuthManagerType {
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult
}

final class AuthManager: AuthManagerType {
    private let auth = Auth.auth()
    
    func createUser(withEmail email: String, password: String) async throws -> AuthDataResult  {
        return try await auth.createUser(withEmail: email, password: password)
    }
    
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult {
        return try await auth.signIn(withEmail: email, password: password)
    }
}


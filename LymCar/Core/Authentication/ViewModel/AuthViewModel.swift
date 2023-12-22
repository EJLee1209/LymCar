//
//  AuthViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

final class AuthViewModel: ObservableObject {
    
    var emailText: String = ""
    var name: String = ""
    var passwordText: String = ""
    var passwordConfirmText: String = ""
    
    @Published var isAgreeForPrivacyPolicy: Bool = false
    @Published var gender: Gender = .male
    
    private let authManager: AuthManagerType
    
    init(authManager: AuthManagerType) {
        self.authManager = authManager
    }
    
    func signIn(withEmail email: String, password: String) {
        Task {
            do {
                let result = try await authManager.signIn(withEmail: email, password: password)
                print("DEBUG: 로그인 성공 \(result)")
            } catch {
                print("DEBUG: 로그인 실패 \(error)")
            }
        }
    }
    
    func createUser(withEmail email: String, password: String) {
        Task {
            do {
                let result = try await authManager.createUser(withEmail: email, password: password)
                print("DEBUG: 회원가입 성공 \(result)")
            } catch {
                print("DEBUG: 회원가입 실패 \(error)")
            }
        }
    }
}

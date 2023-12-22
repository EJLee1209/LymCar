//
//  AuthViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

final class AuthViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var emailText: String = ""
    @Published var nameText: String = ""
    @Published var passwordText: String = ""
    @Published var passwordConfirmText: String = ""
    @Published var isAgreeForPrivacyPolicy: Bool = false
    @Published var gender: Gender = .male
    @Published var authResult: AuthResult = .none
    
    private let authManager: AuthManagerType
    
    //MARK: - Lifecycle
    init(authManager: AuthManagerType) {
        self.authManager = authManager
    }
    
    //MARK: - Helpers
    func signIn(withEmail email: String, password: String) {
        authResult = .loading
        
        Task {
            if let errorMsg = await authManager.signIn(withEmail: email, password: password) {
                await MainActor.run {
                    authResult = .failToSignIn(errorMsg: errorMsg)
                }
                return
            }
            
            await MainActor.run {
                authResult = .successToSignIn
            }
        }
    }
    
    func createUser() {
        authResult = .loading
        
        Task {
            if let errorMsg = await authManager.createUser(withEmail: emailText, password: passwordText) {
                
                await MainActor.run {
                    authResult = .failToCreateUser(errorMsg: errorMsg)
                }
                return
            }
            await MainActor.run {
                authResult = .successToCreateUser
            }
        }
    }
    
    func buttonIsEnabled(_ authStep: AuthStep) -> Bool {
        switch authStep {
        case .email:
            return emailText != ""
        case .gender:
            return true
        case .name:
            return nameText != ""
        case .password:
            return passwordText.count >= 8
        case .passwordConfirm:
            return passwordText == passwordConfirmText
        case .privacyPolicy:
            return isAgreeForPrivacyPolicy
        }
    }
    
    func clearProperties() {
        emailText = ""
        nameText = ""
        passwordText = ""
        passwordConfirmText = ""
        isAgreeForPrivacyPolicy = false
        gender = .male
        authResult = .none
    }
}

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
    @Published var authState: AuthState = .none
    
    private let authManager: AuthManagerType
    
    //MARK: - Lifecycle
    init(authManager: AuthManagerType) {
        self.authManager = authManager
    }
    
    //MARK: - Helpers
    func signIn(withEmail email: String, password: String) {
        authState = .loading
        
        Task {
            let result = await authManager.signIn(withEmail: email, password: password)
            await MainActor.run {
                switch result {
                case .success(let user):
                    authState = .successToSignIn
                    print("DEBUG: sign in user \(user)")
                case .failure(let errorMessage):
                    authState = .failToSignIn(errorMsg: errorMessage)
                }
                
            }
        }
    }
    
    func createUser() {
        authState = .loading
        
        Task {
            let result = await authManager.createUser(
                withEmail: emailText,
                password: passwordText,
                gender: gender,
                name: nameText
            )
            await MainActor.run {
                switch result {
                case .success(let user):
                    authState = .successToCreateUser
                    print("DEBUG: create user \(user)")
                case .failure(let errorMessage):
                    authState = .failToCreateUser(errorMsg: errorMessage)
                }
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
        authState = .none
    }
    
    deinit {
        print("DEBUG: AuthViewModel is deinitialize")
        
    }
}

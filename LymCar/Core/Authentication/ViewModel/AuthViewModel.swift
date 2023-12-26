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
    @Published var viewState: ViewState<User> = .none
    
    var alertMessage: String = ""
    @Published var alertIsPresented: Bool = false
    
    //MARK: - Helpers
    func signIn(withEmail email: String, password: String) {
        viewState = .loading
        
        Task {
            let result = await AuthManager.shared.signIn(withEmail: email, password: password)
            await MainActor.run {
                switch result {
                case .success(let user):
                    viewState = .successToNetworkRequest(response: user)
                case .failure(let errorMessage):
                    viewState = .failToNetworkRequest
                    alertMessage = errorMessage
                    alertIsPresented = true
                }
                
            }
        }
    }
    
    func createUser() {
        viewState = .loading
        
        Task {
            let result = await AuthManager.shared.createUser(
                withEmail: emailText,
                password: passwordText,
                gender: gender,
                name: nameText
            )
            await MainActor.run {
                alertIsPresented = true
                
                switch result {
                case .success(let user):
                    viewState = .successToNetworkRequest(response: user)
                    alertMessage = "회원가입이 완료되었습니다!"
                case .failure(let errorMessage):
                    viewState = .failToNetworkRequest
                    alertMessage = errorMessage
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
        viewState = .none
    }
    
    deinit {
        print("DEBUG: AuthViewModel is deinitialize")
        
    }
}

//
//  LoginViewModel.swift
//  LymCar
//
//  Created by 이은재 on 1/6/24.
//

import SwiftUI

extension LoginView {
    final class ViewModel: ObservableObject {
        @AppStorage("email") var emailText: String = ""
        @Published var passwordText: String = ""
        @Published var viewState: ViewState<User> = .none
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        
        
        private let authManager: AuthManagerType
        
        init(authManager: AuthManagerType) {
            self.authManager = authManager
        }
        
        func signIn() {
            viewState = .loading
            
            Task {
                let result = await authManager.signIn(withEmail: emailText, password: passwordText)
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
    }
}

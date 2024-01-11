//
//  AuthViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

extension RegisterView {
    
    final class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var authStep: AuthStep = .email
        @Published var emailText: String = ""
        @Published var emailCode: Int? = nil
        @Published var nameText: String = ""
        @Published var passwordText: String = ""
        @Published var passwordConfirmText: String = ""
        @Published var isAgreeForPrivacyPolicy: Bool = false
        @Published var gender: Gender = .male
        @Published var viewState: ViewState<User> = .none
        
        var authNum: Int? = nil
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        
        private let authManager: AuthManagerType
        
        init(authManager: AuthManagerType) {
            self.authManager = authManager
        }
        
        //MARK: - Helpers
        
        func sendEmailVerification() {
            viewState = .loading
            
            Task {
                do {
                    let emailVerification = try await authManager.sendEmailVerification(emailText)
                    
                    await MainActor.run {
                        viewState = .none
                        guard let authNum = emailVerification.authNum else {
                            alertMessage = "메일 전송에 실패했습니다. 올바른 이메일을 입력해주세요"
                            alertIsPresented = true
                            return
                        }
                        
                        print("DEBUG: 인증 번호는 \(authNum) 입니다.")
                        self.authNum = authNum
                        authStep = .emailVerification
                    }
                } catch {
                    await MainActor.run {
                        alertMessage = authManager.getErrorMsgFromError(error)
                        alertIsPresented = true
                        viewState = .none
                        
                        print("DEBUG: 에러 발생 \(error)")
                    }
                }
            }
        }
        
        func checkVerifyCode() {
            if authNum! == emailCode {
                authStep = .gender
            } else {
                alertMessage = "인증 코드가 틀렸습니다"
                alertIsPresented = true
            }
        }
        
        private func createUser() {
            viewState = .loading
            
            Task {
                do {
                    let user = try await authManager.createUser(
                        withEmail: emailText,
                        password: passwordText,
                        gender: gender,
                        name: nameText
                    )
                    
                    await MainActor.run {
                        alertMessage = "회원가입이 완료되었습니다!"
                        alertIsPresented = true
                        viewState = .successToNetworkRequest(response: user)
                    }
                } catch {
                    await MainActor.run {
                        alertMessage = authManager.getErrorMsgFromError(error)
                        alertIsPresented = true
                        viewState = .failToNetworkRequest
                    }
                }
            }
        }
        
        func buttonIsEnabled() -> Bool {
            switch authStep {
            case .email:
                return emailText != ""
            case .emailVerification:
                return String(emailCode ?? 0).count == 6
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
        
        func buttonAction() {
            guard buttonIsEnabled() else { return }
            
            switch authStep {
            case .email:
                // 인증 코드 메일 발송
                sendEmailVerification()
            case .emailVerification:
                // 인증 코드 확인
                checkVerifyCode()
            case .privacyPolicy:
                // 회원가입
                createUser()
            default:
                // 다음 step
                authStep = AuthStep(rawValue: authStep.rawValue + 1)!
            }
        }
        
    }
    
}

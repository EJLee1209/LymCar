//
//  AuthManager.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation
import FirebaseAuth

protocol AuthManagerType {
    func createUser(withEmail email: String, password: String) async -> String?
    func signIn(withEmail email: String, password: String) async -> String?
}

final class AuthManager: AuthManagerType {
    private let auth = Auth.auth()
    
    func createUser(withEmail email: String, password: String) async -> String?  {
        do {
            try await auth.createUser(withEmail: email, password: password)
            return nil
        } catch {
            switch error {
            case AuthErrorCode.emailAlreadyInUse:
                return "이미 사용중인 이메일입니다"
            case AuthErrorCode.invalidEmail:
                return "잘못된 이메일 형식입니다"
            case AuthErrorCode.networkError:
                return "네트워크 연결 상태를 확인해주세요"
            default:
                return "알 수 없는 오류가 발생했습니다"
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async -> String? {
        do {
            try await auth.signIn(withEmail: email, password: password)
            return nil
        } catch {
            switch error {
            case AuthErrorCode.invalidEmail:
                return "잘못된 이메일 형식입니다"
            case AuthErrorCode.unverifiedEmail:
                return "등록되지 않은 이메일입니다"
            case AuthErrorCode.wrongPassword:
                return "비밀번호가 틀렸습니다"
            case AuthErrorCode.tooManyRequests:
                return "여러 번의 로그인 실패로 인해 계정 접근이 일시적으로 비활성화 되었습니다. 나중에 다시 시도해주세요"
            case AuthErrorCode.networkError:
                return "네트워크 연결 상태를 확인해주세요"
            default:
                print("DEBUG: 로그인 실패 \(error)")
                return "알 수 없는 오류가 발생했습니다"
            }
        }
    }
}


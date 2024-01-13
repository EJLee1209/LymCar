//
//  AuthManagerType.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import Foundation
import Firebase

protocol AuthManagerType {
    func sendEmailVerification(_ email: String) async throws -> EmailVerification
    
    func createUser(
        withEmail email: String,
        password: String,
        gender: Gender,
        name: String
    ) async throws -> User
    
    func signIn(
        withEmail email: String,
        password: String
    ) async throws -> User
    
    func checkCurrentUser() async throws -> User?
    
    func logout() throws
    
    func updateFcmToken(_ token: String) async
    
    func deleteUser(email: String, password: String) async throws
}

extension AuthManagerType {
    func getErrorMsgFromError(_ error: Error) -> String {
        switch error {
            /// Auth 공통 에러
        case AuthErrorCode.networkError:
            return "네트워크 연결 상태를 확인해주세요"
        case AuthErrorCode.tooManyRequests:
            return "많은 서버 요청 시도를 했기 때문에 일시적으로 차단되었습니다\n잠시 후 다시 시도해주세요"
            /// 로그인 에러
        case AuthErrorCode.invalidEmail:
            return "잘못된 이메일 형식입니다"
        case AuthErrorCode.wrongPassword:
            return "비밀번호가 틀렸습니다"
        case AuthErrorCode.invalidCredential:
            return "이메일 또는 비밀번호 오류입니다"
            /// 회원가입 에러
        case AuthErrorCode.emailAlreadyInUse:
            return "이미 사용중인 이메일입니다"
            /// currentUser가 nil일 때
        case AuthErrorCode.nullUser:
            return "사용자 정보를 가져오지 못했습니다"
            /// node.js 서버 에러
        case NetworkError.invalidURL:
            return NetworkError.invalidURL.rawValue
        case NetworkError.invalidServerResponse:
            return NetworkError.invalidServerResponse.rawValue
        default:
            return "요청 실패\n\(error.localizedDescription)"
        }
    }
}

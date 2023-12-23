//
//  AuthResult.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

enum AuthState: Equatable {
    case none
    case loading
    case successToCreateUser(user: User)
    case failToCreateUser(errorMsg: String)
    case successToSignIn(user: User)
    case failToSignIn(errorMsg: String)
    
    var alertIsPresented: Bool {
        switch self {
        case .successToCreateUser, .failToCreateUser, .failToSignIn:
            return true
        default:
            return false
        }
    }
    
    var alertMessage: String {
        switch self {
        case .successToCreateUser:
            return "회원가입 완료"
        case .failToCreateUser(let errorMsg):
            return errorMsg
        case .failToSignIn(let errorMsg):
            return errorMsg
        default:
            return ""
        }
    }
}

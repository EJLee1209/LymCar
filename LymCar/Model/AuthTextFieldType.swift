//
//  AuthTextFieldType.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

enum AuthTextFieldType: String {
    case name = "이름"
    case password = "비밀번호"
    case confirmPassword = "비밀번호 확인"
    
    var placeHolder: String {
        switch self {
        case .name:
            return "이름을 입력해주세요"
        case .password:
            return "비밀번호를 입력해주세요"
        case .confirmPassword:
            return "비밀번호를 확인해주세요"
        }
    }
}

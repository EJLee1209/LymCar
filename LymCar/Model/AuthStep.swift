//
//  AuthStep.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

enum AuthStep: Int {
    case email
    case gender
    case name
    case password
    case passwordConfirm
    case privacyPolicy
    
    var title: String {
        switch self {
        case .email:
            return "이메일 인증"
        default:
            return "사용자 정보"
        }
    }
    
    var description: String {
        switch self {
        case .email:
            return "사용 가능한 이메일을 입력해주세요"
        case .gender:
            return "성별을 선택해주세요"
        case .name:
            return "이름을 입력해주세요"
        case .password:
            return "비밀번호를 입력해주세요"
        case .passwordConfirm:
            return "비밀번호를 확인해주세요"
        case .privacyPolicy:
            return "개인정보처리방침에 동의해주세요"
        }
    }
    
    var subTitle: String {
        switch self {
        case .email:
            return "이메일"
        case .gender:
            return "성별"
        case .name:
            return "이름"
        case .password:
            return "비밀번호"
        case .passwordConfirm:
            return "비밀번호 확인"
        case .privacyPolicy:
            return "개인정보처리방침"
        }
    }
}

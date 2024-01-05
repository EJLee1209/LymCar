//
//  MenuType.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

/// MenuView의 Menu List Items
enum MenuType: String, CaseIterable {
    case editFavorite = "즐겨찾기 편집"
    case updateInformation = "업데이트 정보"
    case privacyPolicy = "개인정보 취급방침"
    case logout = "로그아웃"
    
    var labelText: String {
        switch self {
        case .updateInformation:
            return "최신 버전 입니다."
        default:
            return ""
        }
    }
    
    var rightContentType: RightContentType {
        switch self {
        case .updateInformation:
            return .label(text: "최신 버전 입니다.")
        default:
            return .rightArrow
        }
    }
}

//
//  MenuType.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

/// MenuView의 Menu List Items
enum FirstMenuType: String, CaseIterable {
    case editFavorite = "즐겨찾기 편집"
    
    var imageName: String {
        switch self {
        case .editFavorite:
            return "map-pin"
        }
    }
}

enum SecondMenuType: String, CaseIterable {
    case updateInformation = "업데이트 정보"
    case privacyPolicy = "개인정보 취급방침"
    
    var labelText: String {
        switch self {
        case .updateInformation:
            return "최신 버전 입니다."
        case .privacyPolicy:
            return ""
        }
    }
}

enum ThirdMenuType: String, CaseIterable {
    case logout = "로그아웃"
}

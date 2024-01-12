//
//  User.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

struct User: Codable, Equatable, Hashable {
    let email: String
    let gender: String
    let name: String
    let uid: String
    
    init(email: String, gender: Gender, name: String, uid: String) {
        self.email = email
        self.name = name
        self.uid = uid
        self.gender = gender.rawValue
    }
    
    var toDict: [String: Any] { 
        return [
            "email": email,
            "gender": gender,
            "name": name,
            "uid": uid
        ]
    }
    
    static let mock = User(email: "dldmswo1209@naver.com", gender: .female, name: "이은재", uid: "yaiSZ4AxPTe1HWWot3zmfeImUe13")
}

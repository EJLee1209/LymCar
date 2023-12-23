//
//  User.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

struct User: Codable {
    let email: String
    let gender: String
    let name: String
    let uid: String
    
    init(email: String, gender: Gender, name: String, uid: String) {
        self.email = email
        self.name = name
        self.uid = uid
        switch gender {
        case .male:
            self.gender = "male"
        case .female:
            self.gender = "female"
        case .none:
            self.gender = "none"
        }
    }
}

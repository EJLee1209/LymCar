//
//  EmailVerification.swift
//  LymCar
//
//  Created by 이은재 on 1/8/24.
//

import Foundation

struct EmailVerification: Codable {
    let state: Bool
    let msg: String
    let authNum: Int?
}

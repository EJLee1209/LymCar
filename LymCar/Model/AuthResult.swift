//
//  AuthResult.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

enum AuthResult {
    case success(user: User)
    case failure(errorMessage: String)
}

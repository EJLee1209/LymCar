//
//  AuthResult.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation

enum FirebaseNetworkResult<T: Decodable> {
    case success(response: T)
    case failure(errorMessage: String)
}

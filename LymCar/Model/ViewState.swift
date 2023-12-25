//
//  AuthResult.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import Foundation

enum ViewState<T>: Equatable where T: Decodable & Equatable {
    case none
    case loading
    case successToNetworkRequest(response: T)
    case failToNetworkRequest
}

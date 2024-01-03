//
//  PushMessage.swift
//  LymCar
//
//  Created by 이은재 on 1/2/24.
//

import Foundation

struct PushMessage: Encodable {
    let fcmToken: String
    let roomId: String
    let from: String
    let msg: String
}

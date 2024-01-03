//
//  Message.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation
import Firebase

struct Message: Codable, Identifiable, Hashable {
    let id: String
    let roomId: String
    let text: String
    let sender: User
    let isSystemMsg: Bool
    var timestamp: Timestamp = Timestamp()
    
    static let mock: Self = .init(id: "", roomId: "", text:"안녕하세요~ 지금 어디신가요?", sender: .mock, isSystemMsg: false)
    
    var prettyTimestamp: String {
        return timestamp.dateValue().dateToString(dateFormat: "a h:mm")
    }
}

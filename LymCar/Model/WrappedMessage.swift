//
//  WrappedMessage.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation

enum WrappedMessage: Hashable {
    case currentUser(message: Message)
    case otherUser(message: Message)
    case system(message: Message)
    
    static var mockMessages: [Self] {
        return [
            .currentUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .currentUser(message: .mock),
            .system(message: .init(id: "", roomId: "", text: "사용자 3님이 입장하셨습니다", sender: .mock, isSystemMsg: true)),
            .currentUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .currentUser(message: .mock),
            .system(message: .init(id: "", roomId: "", text: "사용자 3님이 입장하셨습니다", sender: .mock, isSystemMsg: true)),
            .currentUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .currentUser(message: .mock),
            .system(message: .init(id: "", roomId: "", text: "사용자 3님이 입장하셨습니다", sender: .mock, isSystemMsg: true)),
            .currentUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .currentUser(message: .mock),
            .system(message: .init(id: "", roomId: "", text: "사용자 3님이 입장하셨습니다", sender: .mock, isSystemMsg: true)),
            .currentUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .otherUser(message: .mock),
            .currentUser(message: .mock),
            .system(message: .init(id: "", roomId: "", text: "사용자 3님이 입장하셨습니다", sender: .mock, isSystemMsg: true))
            
        ]
    }
}

//
//  MessageManagerType.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import Foundation

protocol MessageManagerType {
    /// 메세지 전송
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    )
    
    /// 새 메세지 리스너 등록
    func subscribeNewMessages(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    )
    
    /// 이전 메세지 가져오기
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage]
    
    
    /// 메세지 페이지 관련 프로퍼티 초기화
    func resetPageProperties()
}

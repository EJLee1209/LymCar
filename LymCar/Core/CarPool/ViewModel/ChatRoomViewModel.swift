//
//  ChatRoomViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation

extension ChatRoomView {
    final class ViewModel: ObservableObject {
        //MARK: - Properties
        @Published var title: String = ""
        @Published var messageText: String = ""
        @Published var messages: [WrappedMessage] = []
        
        let carPool: CarPool
        let currentUser: User
        let carPoolManager: CarPoolManagerType
        
        //MARK: - LifeCycle
        init(
            carPool: CarPool,
            currentUser: User,
            carPoolManager: CarPoolManagerType
        ) {
            self.carPool = carPool
            self.currentUser = currentUser
            self.carPoolManager = carPoolManager
            
            title = "\(carPool.departurePlace.placeName) - \(carPool.destination.placeName)"
            
            fetchMessageListener()
        }
        
        //MARK: - Helpers
        
        func sendMessage() {
            carPoolManager.sendMessage(
                sender: currentUser,
                roomId: carPool.id,
                text: messageText,
                isSystemMsg: false
            )
            
            messageText.removeAll()
        }
        
        private func fetchMessageListener() {
            carPoolManager.fetchMessageListener(roomId: carPool.id) { [weak self] messages in
                DispatchQueue.main.async {
                    self?.messages = messages
                }
            }
        }
    }
}

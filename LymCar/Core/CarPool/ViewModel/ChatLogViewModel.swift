//
//  ChatRoomViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation

extension ChatLogView {
    final class ViewModel: ObservableObject {
        //MARK: - Properties
        @Published var carPool: CarPool
        @Published var title: String = ""
        @Published var messageText: String = ""
        @Published var prevMessages: [WrappedMessage] = []
        @Published var newMessages: [WrappedMessage] = []
        @Published var isExit: Bool = false
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        var alertPositiveAction: (() -> Void)?
        
        var messageListenerExist: Bool = false
        
        
        let currentUser: User
        let carPoolManager: CarPoolManagerType
        
        var showDeactivateCarPoolButton: Bool {
            return carPool.participants.first == currentUser.uid && carPool.isActivate
        }
        
        var messages: [WrappedMessage] {
            return prevMessages + newMessages
        }
        
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
        
        func fetchMessages() {
            Task {
                let prev = await carPoolManager.fetchMessages(roomId: carPool.id)
                
                if !messageListenerExist {
                    subscribeNewMessage()
                }
                await MainActor.run {
                    prevMessages.insert(contentsOf: prev, at: 0)
                }
            }
        }
        
        private func subscribeNewMessage() {
            messageListenerExist = true
            
            carPoolManager.subscribeNewMessages(roomId: carPool.id) { [weak self] newMessages in
                self?.newMessages = newMessages
            }
        }
        
        func subscribeCarPool() {
            carPoolManager.subscribeCarPool(roomId: carPool.id) { [weak self] result in
                switch result {
                case .success(let carPool):
                    self?.carPool = carPool
                case .failure(let errorMessage):
                    print("DEBUG: Fail to subscribeCarPool with error \(errorMessage)")
                }
            }
        }
        
        func onDisappear() {
            carPoolManager.removeMessageListener()
            carPoolManager.removeCarPoolListener()
            messageListenerExist = false
            
            carPoolManager.resetPageProperties()
            prevMessages.removeAll()
            newMessages.removeAll()
        }
        
        func deactivateCarPoolButtonAction() {
            alertPositiveAction = deactivateCarPool
            alertMessage = "카풀을 마감하면 더이상 다른 사람들이 채팅방에 참여할 수 없습니다. 정말로 마감하시겠습니까?"
            alertIsPresented = true
        }
        
        func exitCarPoolButtonAction() {
            alertPositiveAction = exitCarPool
            alertMessage = "정말로 채팅방을 나가시겠습니까?"
            alertIsPresented = true
        }
        
        
        func deactivateCarPool() {
            alertPositiveAction = nil
            
            Task {
                let result = await carPoolManager.deactivate(roomId: carPool.id)
                
                await MainActor.run {
                    switch result {
                    case .success(let successMessage):
                        carPoolManager.sendMessage(
                            sender: currentUser,
                            roomId: carPool.id,
                            text: successMessage,
                            isSystemMsg: true
                        )
                        carPool.isActivate = false
                    case .failure(let errorMessage):
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
                
            }
        }
        
        func exitCarPool() {
            alertPositiveAction = nil
            
            Task {
                let result = await carPoolManager.exit(user: currentUser, roomId: carPool.id)
                
                await MainActor.run {
                    switch result {
                    case .success:
                        isExit = true
                    case .failure(let errorMessage):
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
            }
        }
    }
}

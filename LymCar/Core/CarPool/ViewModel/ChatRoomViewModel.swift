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
        @Published var isExit: Bool = false
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        var alertPositiveAction: (() -> Void)?
        
        var carPool: CarPool
        let currentUser: User
        let carPoolManager: CarPoolManagerType
        
        var showDeactivateCarPoolButton: Bool {
            return carPool.participants.first == currentUser.uid && carPool.isActivate
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

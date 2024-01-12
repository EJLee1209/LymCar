//
//  ChatRoomViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/28/23.
//

import Foundation
import Combine

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
        var alertRole: AlertRole = .none
        
        var messageListenerExist: Bool = false
        
        var showDeactivateCarPoolButton: Bool {
            return carPool.participants.first == currentUser.uid && carPool.isActivate
        }
        
        var messages: [WrappedMessage] {
            return prevMessages + newMessages
        }

        private let currentUser: User
        private let carPoolManager: CarPoolManagerType
        private let messageManager: MessageManagerType
        
        //MARK: - LifeCycle
        init(
            carPool: CarPool,
            currentUser: User,
            carPoolManager: CarPoolManagerType,
            messageManager: MessageManagerType
        ) {
            self.carPool = carPool
            self.currentUser = currentUser
            self.carPoolManager = carPoolManager
            self.messageManager = messageManager
            
            title = "\(carPool.departurePlace.placeName) - \(carPool.destination.placeName)"
        }
        
        
        //MARK: - Helpers
        
        // 메세지 전송
        func sendMessage() {
            messageManager.sendMessage(
                sender: currentUser,
                roomId: carPool.id,
                text: messageText,
                isSystemMsg: false
            )
            
            messageText.removeAll()
        }
        
        // 메세지 데이터 읽기 (with Paging)
        func fetchMessages() {
            Task {
                let prev = try await messageManager.fetchMessages(roomId: carPool.id)
                
                if !messageListenerExist {
                    subscribeNewMessage()
                }
                await MainActor.run {
                    prevMessages.insert(contentsOf: prev, at: 0)
                }
            }
        }
        
        // 새로운 메세지 구독
        private func subscribeNewMessage() {
            messageListenerExist = true
            
            messageManager.subscribeNewMessages(roomId: carPool.id) { [weak self] newMessages in
                self?.newMessages = newMessages
            }
        }
        
        // 현재 카풀방 구독
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
        
        func showAlert(
            role: AlertRole,
            message: String
        ) {
            alertRole = role
            alertMessage = message
            alertIsPresented = true
        }
        
        // 카풀 비활성화 버튼 클릭 시 alert 표시
        func deactivateCarPoolButtonAction() {
            showAlert(
                role: .both(positiveAction: deactivateCarPool, negativeAction: { }),
                message: "카풀을 마감하면 더이상 다른 사람들이 채팅방에 참여할 수 없습니다. 정말로 마감하시겠습니까?"
            )
        }
        
        // 카풀 비활성화
        private func deactivateCarPool() {
            Task {
                let result = await carPoolManager.deactivate(roomId: carPool.id)
                
                await MainActor.run {
                    switch result {
                    case .success(let successMessage):
                        messageManager.sendMessage(
                            sender: currentUser,
                            roomId: carPool.id,
                            text: successMessage,
                            isSystemMsg: true
                        )
                        carPool.isActivate = false
                    case .failure(let errorMessage):
                        alertRole = .positive(action: { })
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
                
            }
        }
        
        // 카풀 퇴장 버튼 클릭 시 alert 표시
        func exitCarPoolButtonAction() {
            showAlert(
                role: .both(positiveAction: exitCarPool, negativeAction: { }),
                message: "정말로 채팅방을 나가시겠습니까?"
            )
        }
        
        // 카풀 퇴장
        private func exitCarPool() {
            Task {
                let result = await carPoolManager.exit(user: currentUser, roomId: carPool.id)
                
                await MainActor.run {
                    switch result {
                    case .success:
                        messageManager.sendMessage(
                            sender: currentUser,
                            roomId: carPool.id,
                            text: "- \(currentUser.name)님이 나갔습니다 -",
                            isSystemMsg: true
                        )
                        isExit = true
                    case .failure(let errorMessage):
                        alertRole = .positive(action: { })
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
            }
        }
        
        // View 생명주기인 onDisappear 에서 수행
        func onDisappear() {
            messageListenerExist = false
            
            messageManager.resetPageProperties()
            prevMessages.removeAll()
            newMessages.removeAll()
        }
    }
}

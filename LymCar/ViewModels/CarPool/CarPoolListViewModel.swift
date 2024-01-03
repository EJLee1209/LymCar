//
//  CarPoolListViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import Foundation

extension CarPoolListView {
    final class ViewModel: ObservableObject {
        @Published var carPoolList: [CarPool] = []
        @Published var alertIsPresented: Bool = false
        @Published var navigateToChatRoomView: Bool = false
        
        var joinedCarPool: CarPool?
        var alertMessage: String = ""
        
        private let user: User
        private let carPoolManager: CarPoolManagerType
        private let messageManager: MessageManagerType
        
        init(
            user: User,
            carPoolManager: CarPoolManagerType,
            messageManager: MessageManagerType
        ) {
            self.user = user
            self.carPoolManager = carPoolManager
            self.messageManager = messageManager
        }
        
        func fetchCarPoolList() {
            Task {
                let list = await carPoolManager.fetchCarPool(gender: user.gender)
                await MainActor.run {
                    carPoolList = list
                }
            }
        }
        
        func joinCarPool(with carPool: CarPool) {
            Task {
                let result = await carPoolManager.join(user: user, carPool: carPool)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let carPool):
                        joinedCarPool = carPool
                        sendJoinMessage(carPoolId: carPool.id)
                        navigateToChatRoomView = true
                    case .failure(let errorMessage):
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
                
            }
        }
        
        func isMyCarPool(_ carPool: CarPool) -> Bool {
            return carPool.participants.contains(user.uid)
        }
        
        private func sendJoinMessage(carPoolId: String) {
            messageManager.sendMessage(sender: user, roomId: carPoolId, text: "- \(user.name)님이 입장했습니다 -", isSystemMsg: true)
        }
        
    }

}


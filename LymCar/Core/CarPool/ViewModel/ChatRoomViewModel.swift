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
        }
        
        //MARK: - Helpers
        
        func sendMessage() {
            
        }
    }
}

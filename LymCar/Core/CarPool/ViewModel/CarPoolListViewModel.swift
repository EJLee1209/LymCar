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
        
        init(
            user: User,
            carPoolManager: CarPoolManagerType
        ) {
            self.user = user
            self.carPoolManager = carPoolManager
            
            fetchCarPoolList()
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
                let result = await carPoolManager.joinCarPool(user: user, carPool: carPool)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let carPool):
                        joinedCarPool = carPool
                        navigateToChatRoomView = true
                    case .failure(let errorMessage):
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
                
            }
        }
        
    }

}


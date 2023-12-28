//
//  CarPoolListViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import Foundation

final class CarPoolListViewModel: ObservableObject {
    @Published var carPoolList: [CarPool] = []
    
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
    
    
}

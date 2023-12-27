//
//  CarPoolListViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import Foundation

final class CarPoolListViewModel: ObservableObject {
    @Published var carPoolList: [CarPool] = []
    
    private let carPoolManager: CarPoolManagerType
    
    init(carPoolManager: CarPoolManagerType) {
        self.carPoolManager = carPoolManager
        fetchCarPoolList()
    }
    
    func fetchCarPoolList() {
        Task {
            let list = await carPoolManager.fetchCarPool()
            await MainActor.run {
                carPoolList = list
            }
        }
    }
}

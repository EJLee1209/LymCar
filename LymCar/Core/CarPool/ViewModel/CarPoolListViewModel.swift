//
//  CarPoolListViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/26/23.
//

import Foundation

final class CarPoolListViewModel: ObservableObject {
    @Published var carPoolList: [CarPool] = []
    
    init() { 
        fetchCarPoolList()
    }
    
    func fetchCarPoolList() {
        Task {
            let list = await CarPoolManager.shared.fetchCarPool()
            await MainActor.run {
                carPoolList = list
            }
        }
    }
}

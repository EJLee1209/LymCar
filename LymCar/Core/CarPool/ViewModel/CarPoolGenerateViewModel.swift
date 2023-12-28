//
//  CarPoolGenerateViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import Foundation
import CoreLocation

extension CarPoolGenerateView {
    final class ViewModel: ObservableObject {
        
        //MARK: - Properties
        @Published var departureDate = Date()
        @Published var personCount = 2
        @Published var genderOptionIsActivate = false
        @Published var departurePlaceText = ""
        @Published var destinationText = ""
        @Published var viewState: ViewState<CarPool> = .none
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        
        private let currentUser: User
        private var departurePlaceCoordinate: CLLocationCoordinate2D
        private var destinationCoordinate: CLLocationCoordinate2D
        
        private let carPoolManager: CarPoolManagerType
        
        //MARK: - LifeCycle
        init(
            currentUser: User,
            departurePlaceText: String,
            destinationText: String,
            departurePlaceCoordinate: CLLocationCoordinate2D,
            destinationCoordinate: CLLocationCoordinate2D,
            carPoolManager: CarPoolManagerType
        ) {
            self.currentUser = currentUser
            self.departurePlaceText = departurePlaceText
            self.destinationText = destinationText
            self.departurePlaceCoordinate = departurePlaceCoordinate
            self.destinationCoordinate = destinationCoordinate
            self.carPoolManager = carPoolManager
        }
        
        //MARK: - Helpers
        func swapLocation() {
            swap(&departurePlaceText, &destinationText)
            swap(&departurePlaceCoordinate, &destinationCoordinate)
        }
        
        func createCarPool() {
            viewState = .loading
            
            Task {
                let result = await carPoolManager.createCarPool(
                    departurePlaceName: departurePlaceText,
                    destinationPlaceName: destinationText,
                    departurePlaceCoordinate: departurePlaceCoordinate,
                    destinationCoordinate: destinationCoordinate,
                    departureDate: departureDate,
                    genderOption: genderOptionIsActivate ? Gender(rawValue: currentUser.gender)! : .none,
                    maxPersonCount: personCount
                )
                
                await MainActor.run {
                    switch result {
                    case .success(let carPool):
                        viewState = .successToNetworkRequest(response: carPool)
                    case .failure(let errorMessage):
                        viewState = .failToNetworkRequest
                        alertIsPresented = true
                        alertMessage = errorMessage
                    }
                }
            }
        }
    }

}


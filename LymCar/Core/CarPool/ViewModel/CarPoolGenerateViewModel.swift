//
//  CarPoolGenerateViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import Foundation
import CoreLocation
import MapKit

extension CarPoolGenerateView {
    final class ViewModel: NSObject, ObservableObject {
        
        //MARK: - Properties
        @Published var departureDate = Date()
        @Published var personCount = 2
        @Published var genderOptionIsActivate = false
        @Published var departurePlaceText = ""
        @Published var destinationText = ""
        @Published var viewState: ViewState<CarPool> = .none
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        
        @Published var localSearchResult: [MKLocalSearchCompletion] = []
        private var searchCompleter = MKLocalSearchCompleter()
        
        private let currentUser: User
        private var departurePlaceCoordinate: CLLocationCoordinate2D?
        private var destinationCoordinate: CLLocationCoordinate2D?
        
        private var searchType: SearchType?
        
        private let carPoolManager: CarPoolManagerType
        private let locationSearchManager: LocationSearchManagerType
        
        //MARK: - LifeCycle
        init(
            currentUser: User,
            departurePlaceText: String,
            destinationText: String,
            departurePlaceCoordinate: CLLocationCoordinate2D?,
            destinationCoordinate: CLLocationCoordinate2D?,
            carPoolManager: CarPoolManagerType,
            locationSearchManager: LocationSearchManagerType
        ) {
            self.currentUser = currentUser
            self.departurePlaceText = departurePlaceText
            self.destinationText = destinationText
            self.departurePlaceCoordinate = departurePlaceCoordinate
            self.destinationCoordinate = destinationCoordinate
            self.carPoolManager = carPoolManager
            self.locationSearchManager = locationSearchManager
            
            super.init()
            
            searchCompleter.delegate = self
        }
        
        //MARK: - Helpers
        func swapLocation() {
            swap(&departurePlaceText, &destinationText)
            swap(&departurePlaceCoordinate, &destinationCoordinate)
        }
        
        func createCarPool() {
            guard let departurePlaceCoordinate = departurePlaceCoordinate,
            let destinationCoordinate = destinationCoordinate else {
                viewState = .failToNetworkRequest
                alertIsPresented = true
                alertMessage = "출발지와 목적지를 설정해주세요"
                return
            }
            
            viewState = .loading
            
            let result = carPoolManager.create(
                departurePlaceName: departurePlaceText,
                destinationPlaceName: destinationText,
                departurePlaceCoordinate: departurePlaceCoordinate,
                destinationCoordinate: destinationCoordinate,
                departureDate: departureDate,
                genderOption: genderOptionIsActivate ? Gender(rawValue: currentUser.gender)! : .none,
                maxPersonCount: personCount
            )
            
            switch result {
            case .success(let carPool):
                viewState = .successToNetworkRequest(response: carPool)
            case .failure(let errorMessage):
                viewState = .failToNetworkRequest
                alertIsPresented = true
                alertMessage = errorMessage
            }
        }
        
        func localSearch(searchType: SearchType) {
            self.searchType = searchType
            
            switch searchType {
            case .departurePlace:
                searchCompleter.queryFragment = departurePlaceText
            case .destination:
                searchCompleter.queryFragment = destinationText
            }
        }
        
        func didSelectLocal(
            with location: MKLocalSearchCompletion
        ) {
            locationSearchManager.locationSearch(location) { searchResult in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch searchResult {
                    case .success(let coordinate):
                        switch searchType {
                        case .departurePlace:
                            departurePlaceCoordinate = coordinate
                            departurePlaceText = location.title
                        case .destination:
                            destinationCoordinate = coordinate
                            destinationText = location.title
                        default:
                            break
                        }
                    case .failure(let errorMessage):
                        alertMessage = errorMessage
                        alertIsPresented = true
                    }
                }
                
            }
        }
        
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension CarPoolGenerateView.ViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        localSearchResult = completer.results
    }
}


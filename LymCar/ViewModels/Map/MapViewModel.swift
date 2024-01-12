//
//  MapViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import Foundation
import MapKit
import SwiftUI

extension MapView {
    
    final class ViewModel: NSObject, ObservableObject {
        //MARK: - Properties
        var departurePlaceText: String = "" {
            didSet {
                searchCompleter.queryFragment = departurePlaceText
                searchType = .departurePlace
            }
        }
        var destinationText: String = "" {
            didSet {
                searchCompleter.queryFragment = destinationText
                searchType = .destination
            }
        }
        var searchType: SearchType = .destination
        
        @Published var searchResults = [MKLocalSearchCompletion]()
        private let searchCompleter = MKLocalSearchCompleter()
        
        @Published var departurePlaceCoordinate: CLLocationCoordinate2D?
        @Published var destinationCoordinate: CLLocationCoordinate2D?
        var userLocationCoordinate: CLLocationCoordinate2D?
        var userLocationText: String = ""
        
        @Published var alertIsPresented: Bool = false
        var alertMessage: String = ""
        
        private let locationSearchManager: LocationSearchManagerType
        
        //MARK: - Lifecycle
        init(locationSearchManager: LocationSearchManagerType) {
            self.locationSearchManager = locationSearchManager
            
            super.init()
            searchCompleter.delegate = self
        }
        
        //MARK: - Helpers
        /// 장소 검색 리스트에서 Row를 선택했을 때 호출
        func didSelectLocation(
            _ location: MKLocalSearchCompletion,
            _ completion: @escaping () -> Void
        ) {
            locationSearchManager.locationSearch(location) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let coordinate):
                    switch searchType {
                    case .departurePlace:
                        departurePlaceText = location.title
                        departurePlaceCoordinate = coordinate
                    case .destination:
                        destinationText = location.title
                        destinationCoordinate = coordinate
                    }
                case .failure(let errorMessage):
                    alertMessage = errorMessage
                    alertIsPresented = true
                }
                
                completion()
            }
        }
        
        func didSelectFavorite(with favorite: Favorite) {
            let coordinate = CLLocationCoordinate2D(
                latitude: favorite.latitude,
                longitude: favorite.longitude
            )
            destinationCoordinate = coordinate
            destinationText = favorite.title
        }
        
        /// 모든 프로퍼티 초기화(MapViewActionButton 클릭시)
        func clearAllPropertiesForLocationSearch() {
            departurePlaceCoordinate = userLocationCoordinate
            destinationCoordinate = nil
            departurePlaceText = userLocationText
            destinationText = ""
            searchResults.removeAll()
        }
    }
}


//MARK: - MKLocalSearchCompleterDelegate

extension MapView.ViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }
}

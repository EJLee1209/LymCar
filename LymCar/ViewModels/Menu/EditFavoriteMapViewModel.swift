//
//  EditFavoriteMapViewModel.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import Foundation
import MapKit
import Combine

extension EditFavoriteMapView {
    final class ViewModel: NSObject, ObservableObject {
        @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.498206, longitude: 127.02761),
            span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        @Published var searchResults = [MKLocalSearchCompletion]()
        private let searchCompleter = MKLocalSearchCompleter()
        
        var searchText: String = "" {
            didSet {
                searchCompleter.queryFragment = searchText
            }
        }
        
        private let locationManager = LocationManager()
        private var cancellable: Set<AnyCancellable> = .init()
        
        override init() {
            super.init()
            
            searchCompleter.delegate = self
        }
        
        func setUserLocation() {
            locationManager.$lastLocation
                .sink { [weak self] location in
                    guard let location = location else { return }
                    self?.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
                .store(in: &cancellable)
        }
    }
}

//MARK: - MKLocalSearchCompleterDelegate
extension EditFavoriteMapView.ViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        print("DEBUG: 검색 결과 \(searchResults)")
    }
}

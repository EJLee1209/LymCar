//
//  EditFavoriteMapViewModel.swift
//  LymCar
//
//  Created by 이은재 on 1/4/24.
//

import Foundation
import MapKit
import Combine

struct Annotation: Identifiable {
    let id: UUID = .init()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

extension EditFavoriteMapView {
    final class ViewModel: NSObject, ObservableObject {
        @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.498206, longitude: 127.02761),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        @Published var searchResults = [MKLocalSearchCompletion]()
        private let searchCompleter = MKLocalSearchCompleter()
        var searchText: String = "" {
            didSet {
                searchCompleter.queryFragment = searchText
            }
        }
        @Published var alertIsPresented = false
        var alertMessage = ""
        
        @Published var showPopUp: Bool = false
        
        @Published var annotations: [Annotation] = []
        var selectedLocationTitle: String = ""
        var selectedLocationSubTitle: String = ""
        var selectedLocationCoordinate: CLLocationCoordinate2D?
        
        private let locationSearchManager: LocationSearchManagerType
        private let locationManager = LocationManager()
        private var cancellable: Set<AnyCancellable> = .init()

        init(locationSearchManager: LocationSearchManagerType) {
            self.locationSearchManager = locationSearchManager
            
            super.init()
            searchCompleter.delegate = self
            searchCompleter.queryFragment = "한림대학교"
        }
        
        //MARK: - Helpers
        
        func setUserLocation() {
            locationManager.$lastLocation
                .sink { [weak self] location in
                    guard let location = location else { return }
                    self?.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
                .store(in: &cancellable)
        }
        
        /// 장소 검색 리스트에서 Row를 선택했을 때 호출
        func didSelectLocation(_ location: MKLocalSearchCompletion) {
            locationSearchManager.locationSearch(location) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let coordinate):
                    selectedLocationTitle = location.title
                    selectedLocationSubTitle = location.subtitle
                    selectedLocationCoordinate = coordinate
                    
                    region = MKCoordinateRegion(
                        center: coordinate,
                        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                    
                    let anno = Annotation(coordinate: coordinate, title: location.title)
                    annotations = [anno]
                case .failure(let errorMessage):
                    alertMessage = errorMessage
                    alertIsPresented = true
                }
            }
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

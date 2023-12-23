//
//  MapViewModel.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import Foundation
import MapKit
import SwiftUI

final class MapViewModel: NSObject, ObservableObject {
    //MARK: - Properties
    var startLocationText: String = "" {
        didSet {
            searchCompleter.queryFragment = startLocationText
            searchType = .startingPoint
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
    
    @Published var startingPointCoordinate: CLLocationCoordinate2D?
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    var userLocationCoordinate: CLLocationCoordinate2D?
    
    //MARK: - Lifecycle
    override init() {
        super.init()
        
        searchCompleter.delegate = self
    }
    
    //MARK: - Helpers
    /// 장소 검색 리스트에서 Row를 선택했을 때 호출
    func didSelectLocation(
        _ location: MKLocalSearchCompletion,
        _ completion: @escaping () -> Void
    ) {
        locationSearch(forLocalSearchCompletion: location) { [weak self] response, error in
            guard let item = response?.mapItems.first else { return }
            let coordinate = item.placemark.coordinate
            
            guard let self = self else { return }
            switch searchType {
            case .startingPoint:
                startLocationText = location.title
                startingPointCoordinate = coordinate
            case .destination:
                destinationText = location.title
                destinationCoordinate = coordinate
            }
            
            completion()
        }
    }
    
    /// MKLocalSearchCompletion을 통해 실제 위치 정보(위도/경도)를 가져옴
    func locationSearch(
        forLocalSearchCompletion localSearch: MKLocalSearchCompletion,
        completion: @escaping(MKLocalSearch.CompletionHandler)
    ) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
    /// 모든 프로퍼티 초기화(MapViewActionButton 클릭시)
    func clearAllPropertiesForLocationSearch() {
        startingPointCoordinate = userLocationCoordinate
        destinationCoordinate = nil
        startLocationText = ""
        destinationText = ""
        searchResults.removeAll()
    }
}

//MARK: - MKLocalSearchCompleterDelegate

extension MapViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
    }
}
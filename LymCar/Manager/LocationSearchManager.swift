//
//  LocationSearchManager.swift
//  LymCar
//
//  Created by 이은재 on 12/29/23.
//

import MapKit

final class LocationSearchManager: LocationSearchManagerType {
    /// 장소 검색 리스트에서 Row를 선택했을 때 호출
    func locationSearch(
        _ location: MKLocalSearchCompletion,
        _ completion: @escaping (LocationSearchResult) -> Void
    ) {
        locationSearch(forLocalSearchCompletion: location) { response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    completion(.failure(errorMessage: "위치 정보를 찾을 수 없습니다"))
                    return
                }
                guard let item = response?.mapItems.first else {
                    completion(.failure(errorMessage: "위치 정보를 찾을 수 없습니다"))
                    return
                }
                let coordinate = item.placemark.coordinate
                completion(.success(coordinate))
            }
        }
    }
    
    /// MKLocalSearchCompletion을 통해 실제 위치 정보(위도/경도)를 가져옴
    private func locationSearch(
        forLocalSearchCompletion localSearch: MKLocalSearchCompletion,
        completion: @escaping(MKLocalSearch.CompletionHandler)
    ) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
}

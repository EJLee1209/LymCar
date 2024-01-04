//
//  LocationSearchManagerType.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import MapKit

protocol LocationSearchManagerType {
    func locationSearch(
        _ location: MKLocalSearchCompletion,
        _ completion: @escaping (LocationSearchResult) -> Void
    )
}

//
//  LocationSearchResult.swift
//  LymCar
//
//  Created by 이은재 on 12/29/23.
//

import CoreLocation

enum LocationSearchResult {
    case success(CLLocationCoordinate2D)
    case failure(errorMessage: String)
}

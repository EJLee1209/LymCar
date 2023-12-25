//
//  MapState.swift
//  LymCar
//
//  Created by 이은재 on 12/20/23.
//

import CoreLocation

enum MapState {
    case none
    case searchingForLocation // 장소 검색 중
    case locationSelected // 장소 선택 됨
}

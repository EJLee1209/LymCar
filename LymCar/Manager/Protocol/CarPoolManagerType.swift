//
//  CarPoolManagerType.swift
//  LymCar
//
//  Created by 이은재 on 1/3/24.
//

import CoreLocation

protocol CarPoolManagerType {
    /// 유저가 참여중인 카풀 리스트 리스너 등록
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void)
    
    /// 카풀 리스너 등록
    func subscribeCarPool(roomId: String, completion: @escaping(FirebaseNetworkResult<CarPool>) -> Void)
    
    /// 카풀 리스트 가져오기
    func fetchCarPool(gender: String) async -> [CarPool]
    
    /// 카풀 생성
    func create(
        user: User,
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 참여
    func join(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 퇴장
    func exit(
        user: User,
        roomId: String
    ) async -> FirebaseNetworkResult<String>

    /// 카풀 마감
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String>
    
}

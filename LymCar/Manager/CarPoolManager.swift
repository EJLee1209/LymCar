//
//  CarPoolManager.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import FirebaseFirestore
import FirebaseAuth
import CoreLocation

enum RoomDocumentField {
    case createdAt
    
}

protocol CarPoolManagerType {
    func fetchMyCarPool() async -> [CarPool]
    
    func fetchCarPool(gender: String) async -> [CarPool]
    
    func createCarPool(
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) async -> FirebaseNetworkResult<CarPool>
}

final class CarPoolManager: CarPoolManagerType {    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    func fetchMyCarPool() async -> [CarPool] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        do {
            let querySnapshot = try await db.collection("Rooms")
                .whereField("participants", arrayContains: uid)
                .getDocuments()
            
            let carPoolList = try querySnapshot.documents.map { try $0.data(as: CarPool.self) }
            return carPoolList
        } catch {
            print("DEBUG: Failed to fetchMyCarPool with error \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchCarPool(gender: String) async -> [CarPool] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        do {
            let querySnapshot = try await db.collection("Rooms")
                .order(by: "departureDate")
                .whereField("departureDate", isGreaterThanOrEqualTo: Date())
                .whereField("genderOption", in: [gender, Gender.none.rawValue])
                .whereField("isActivate", isEqualTo: true)
                .order(by: "createdAt")
                .getDocuments()
            
            return try querySnapshot.documents
                .map { try $0.data(as: CarPool.self) }
        } catch {
            print("DEBUG: Failed to fetchCarPool with error \(error.localizedDescription)")
            return []
        }
    }
    
    func createCarPool(
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) async -> FirebaseNetworkResult<CarPool> {
        guard let uid = auth.currentUser?.uid else { return .failure(errorMessage: "사용자 정보를 가져오지 못했습니다") }
        let ref = db.collection("Rooms").document()
        
        let departurePlace = Location(
            placeName: departurePlaceName,
            latitude: departurePlaceCoordinate.latitude,
            longitude: departurePlaceCoordinate.longitude
        )
        let destination = Location(
            placeName: destinationPlaceName,
            latitude: destinationCoordinate.latitude,
            longitude: destinationCoordinate.longitude
        )
        
        let carPool = CarPool(
            id: ref.documentID,
            departurePlace: departurePlace,
            destination: destination,
            departureDate: departureDate,
            genderOption: genderOption.rawValue,
            participants: [uid],
            maxPersonCount: maxPersonCount
        )
        
        do {
            try ref.setData(from: carPool)
            return .success(response: carPool)
        } catch {
            return .failure(errorMessage: "카풀방을 생성하는데 실패했습니다. 잠시 후 다시 시도해주세요")
        }
    }
}

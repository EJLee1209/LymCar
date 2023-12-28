//
//  AppData.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation
import Firebase
import CoreLocation

final class AppData: ObservableObject {
    
    //MARK: - Properties
    
    @Published var currentUser: User?
    @Published var userCarPoolList: [CarPool] = []
    var departureLocation: Location?
    var destination: Location?
    
    private let authManager: AuthManagerType
    private let carPoolManager: CarPoolManagerType
    
    init(authManager: AuthManagerType, carPoolManager: CarPoolManagerType) {
        self.authManager = authManager
        self.carPoolManager = carPoolManager
    }
    
    //MARK: - Helpers
    
    func didSelectLocation(
        departurePlaceName: String,
        destinationName: String,
        departureLocationCoordinate: CLLocationCoordinate2D?,
        destinationCoordinate: CLLocationCoordinate2D?
    ) {
        if let departCoord = departureLocationCoordinate {
            let departureLocation = Location(
                placeName: departurePlaceName,
                latitude: departCoord.latitude,
                longitude: departCoord.longitude
            )
            self.departureLocation = departureLocation
        }
        if let destCoord = destinationCoordinate {
            let destination = Location(
                placeName: destinationName,
                latitude: destCoord.latitude,
                longitude: destCoord.longitude
            )
            self.destination = destination
        }
    }
    
    func checkUserAndFetchUserCarPool() async -> User? {
        let currentUser = await authManager.checkCurrentUser()
        fetchUserCarPool()
        
        await MainActor.run {
            self.currentUser = currentUser
            self.userCarPoolList = userCarPoolList
        }
        
        return currentUser
    }
    
    func fetchUserCarPool() {
        Task {
            let carPool = await carPoolManager.fetchMyCarPool()
            
            await MainActor.run {
                self.userCarPoolList = carPool
            }
        }
    }
    
    func logout() {
        authManager.logout()
        currentUser = nil
        userCarPoolList = []
    }
    
    //MARK: - Make ViewModel
    
    func makeAuthVM() -> AuthViewModel {
        return AuthViewModel(authManager: self.authManager)
    }
    
    func makeMapVM() -> MapViewModel {
        return MapViewModel()
    }
    
    func makeCarPoolListVM() -> CarPoolListViewModel? {
        guard let user = currentUser else { return nil }
        
        return CarPoolListViewModel(
            user: user,
            carPoolManager: self.carPoolManager
        )
    }
    
    func makeCarPoolGenerateVM() -> CarPoolGenerateViewModel? {
        guard let user = currentUser else { return nil }
        guard let departureLocation = departureLocation else { return nil }
        guard let destination = destination else { return nil }
        
        return CarPoolGenerateViewModel(
            currentUser: user,
            departurePlaceText: departureLocation.placeName,
            destinationText: destination.placeName,
            departurePlaceCoordinate: CLLocationCoordinate2D(latitude: departureLocation.latitude, longitude: departureLocation.longitude),
            destinationCoordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude),
            carPoolManager: self.carPoolManager
        )
    }
}

//
//  AppData.swift
//  LymCar
//
//  Created by 이은재 on 12/23/23.
//

import Foundation
import Firebase
import CoreLocation

enum AlertRole {
    case withAction(() -> Void)
    case cancel
}

final class AppData: ObservableObject {
    
    //MARK: - Properties
    
    @Published var currentUser: User?
    @Published var userCarPoolList: [CarPool] = []
    var departureLocation: Location?
    var destination: Location?
    var userLocation: Location?
    
    private let authManager: AuthManagerType
    private let carPoolManager: CarPoolManagerType
    private let locationSearchManager: LocationSearchManagerType
    
    @Published var alertIsPresented: Bool = false
    var alertMessage: String = ""
    var alertRole: AlertRole = .cancel
    
    init(
        authManager: AuthManagerType,
        carPoolManager: CarPoolManagerType,
        locationSearchManager: LocationSearchManagerType
    ) {
        self.authManager = authManager
        self.carPoolManager = carPoolManager
        self.locationSearchManager = locationSearchManager
    }
    
    //MARK: - Helpers
    
    func alert(
        message: String,
        isPresented: Bool,
        role: AlertRole
    ) {
        alertMessage = message
        alertIsPresented = isPresented
        alertRole = role
    }
    
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
        }
        
        return currentUser
    }
    
    func fetchUserCarPool() {
        carPoolManager.fetchUserCarPoolListener { list in
            DispatchQueue.main.async { [weak self] in
                self?.userCarPoolList = list
            }
        }
    }
    
    func logout() {
        authManager.logout()
        currentUser = nil
        userCarPoolList = []
        
        carPoolManager.removeUserCarPoolListener()
    }
    
    func clearLocation() {
        departureLocation = userLocation
        destination = nil
    }
    
    //MARK: - Make ViewModel
    
    func makeAuthVM() -> AuthViewModel {
        return AuthViewModel(authManager: self.authManager)
    }
    
    func makeMapVM() -> MapView.ViewModel {
        return .init(locationSearchManager: locationSearchManager)
    }
    
    func makeCarPoolListVM() -> CarPoolListView.ViewModel? {
        guard let user = currentUser else { return nil }
        
        return .init(
            user: user,
            carPoolManager: self.carPoolManager
        )
    }
    
    func makeCarPoolGenerateVM() -> CarPoolGenerateView.ViewModel? {
        guard let user = currentUser else { return nil }
        
        var departurePlaceCoordinate: CLLocationCoordinate2D?
        var destinationCoordinate: CLLocationCoordinate2D?
        
        if let departureLocation = departureLocation {
            departurePlaceCoordinate = CLLocationCoordinate2D(
                latitude: departureLocation.latitude,
                longitude: departureLocation.longitude
            )
        }
        
        if let destination = destination {
            destinationCoordinate = CLLocationCoordinate2D(
                latitude: destination.latitude,
                longitude: destination.longitude
            )
        }
        
        return .init(
            currentUser: user,
            departurePlaceText: departureLocation?.placeName ?? "",
            destinationText: destination?.placeName ?? "",
            departurePlaceCoordinate: departurePlaceCoordinate,
            destinationCoordinate: destinationCoordinate,
            carPoolManager: self.carPoolManager,
            locationSearchManager: self.locationSearchManager
        )
    }
    
    func makeChatRoomVM(with carPool: CarPool) -> ChatRoomView.ViewModel? {
        guard let user = currentUser else { return nil }
        
        return ChatRoomView.ViewModel(
            carPool: carPool,
            currentUser: user,
            carPoolManager: carPoolManager
        )
    }
}

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
    case positive(action: () -> Void)
    case negative(action: () -> Void)
    case both(positiveAction: () -> Void, negativeAction: () -> Void)
    case none
}

final class AppData: ObservableObject {
    
    //MARK: - Properties
    
    @Published var currentUser: User?
    @Published var userCarPoolList: [CarPool] = []
    
    @Published var token: String?
    
    var departurePlaceName: String = ""
    var destinationName: String = ""
    var departureLocationCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var userLocationCoordinate: CLLocationCoordinate2D?
    
    let authManager: AuthManagerType
    let carPoolManager: CarPoolManagerType
    let locationSearchManager: LocationSearchManagerType
    let messageManager: MessageManagerType
    
    @Published var alertIsPresented: Bool = false
    var alertMessage: String = ""
    var alertRole: AlertRole = .none
    
    init(
        authManager: AuthManagerType,
        carPoolManager: CarPoolManagerType,
        locationSearchManager: LocationSearchManagerType,
        messageManager: MessageManagerType
    ) {
        self.authManager = authManager
        self.carPoolManager = carPoolManager
        self.locationSearchManager = locationSearchManager
        self.messageManager = messageManager
    }
    
    //MARK: - Helpers
    
    func alert(
        message: String,
        role: AlertRole
    ) {
        alertMessage = message
        alertRole = role
        alertIsPresented = true
    }
    
    func didSelectLocation(
        departurePlaceName: String,
        destinationName: String,
        departureLocationCoordinate: CLLocationCoordinate2D?,
        destinationCoordinate: CLLocationCoordinate2D?
    ) {
        self.departurePlaceName = departurePlaceName
        self.destinationName = destinationName
        self.departureLocationCoordinate = departureLocationCoordinate
        self.destinationCoordinate = destinationCoordinate
    }
    
    func didSelectFavorite(with favorite: Favorite) {
        let coordinate = CLLocationCoordinate2D(
            latitude: favorite.latitude,
            longitude: favorite.longitude
        )
        destinationName = favorite.title
        destinationCoordinate = coordinate
    }
    
    func checkUserAndFetchUserCarPool() async -> User? {
        do {
            let currentUser = try await authManager.checkCurrentUser()
            
            await MainActor.run {
                self.currentUser = currentUser
            }
            subscribeUserCarPool()
            
            return currentUser
        } catch {
            return nil
        }
    }
    
    func subscribeUserCarPool() {
        carPoolManager.subscribeUserCarPool { [weak self] list in
            self?.userCarPoolList = list
            
            print("DEBUG: 유저 카풀 목록 수 \(list.count)")
        }
    }
    
    func logout() {
        try? authManager.logout()
        currentUser = nil
        userCarPoolList = []
    }
    
    func clearLocation() {
        departureLocationCoordinate = userLocationCoordinate
        destinationCoordinate = nil
    }
    
    func updateFcmToken(_ token: String) {
        Task {
            await authManager.updateFcmToken(token)
        }
    }
    
    
}

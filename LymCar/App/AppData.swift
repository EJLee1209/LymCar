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
    var alertRole: AlertRole = .cancel
    
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
        self.departurePlaceName = departurePlaceName
        self.destinationName = destinationName
        self.departureLocationCoordinate = departureLocationCoordinate
        self.destinationCoordinate = destinationCoordinate
    }
    
    func checkUserAndFetchUserCarPool() async -> User? {
        let currentUser = await authManager.checkCurrentUser()
        subscribeUserCarPool()
        
        await MainActor.run {
            self.currentUser = currentUser
        }
        
        return currentUser
    }
    
    func subscribeUserCarPool() {
        carPoolManager.subscribeUserCarPool { [weak self] list in
            self?.userCarPoolList = list
        }
    }
    
    func logout() {
        authManager.logout()
        currentUser = nil
        userCarPoolList = []
        
        carPoolManager.removeUserCarPoolListener()
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

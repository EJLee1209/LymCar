//
//  LocationManager.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        locationManager.stopUpdatingLocation()
        
        self.lastLocation = locations.first
    }
}

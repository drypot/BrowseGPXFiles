//
//  LocationObserver.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2024-04-13.
//

import Foundation
import CoreLocation
import Combine

class LocationObserver: NSObject, ObservableObject {

    private var manager: CLLocationManager
    
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var error: Error?
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        manager.requestLocation()
    }

    func startMonitoringLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopMonitoringLocation() {
        manager.stopUpdatingLocation()
    }

}

extension LocationObserver: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
}

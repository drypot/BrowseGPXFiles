//
//  LocationPublisher.swift
//  DrypotGPX
//
//  Created by drypot on 2024-04-14.
//

import Foundation
import CoreLocation
import Combine

class LocationPublisher: NSObject {
    
    private var manager: CLLocationManager
    
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.manager = locationManager
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

}

extension LocationPublisher: CLLocationManagerDelegate {
    
}

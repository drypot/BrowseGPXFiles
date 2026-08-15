//
//  LocationObserver.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2024-04-13.
//

import Foundation
import CoreLocation
import Combine

public class LocationObserver: NSObject, ObservableObject {

    private var manager: CLLocationManager
    
    @Published public private(set) var currentLocation: CLLocation?
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus
    @Published public private(set) var error: Error?
    
    public init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }
    
    public func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func requestLocation() {
        manager.requestLocation()
    }

    public func startMonitoringLocation() {
        manager.startUpdatingLocation()
    }
    
    public func stopMonitoringLocation() {
        manager.stopUpdatingLocation()
    }

}

extension LocationObserver: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
    }
    
}

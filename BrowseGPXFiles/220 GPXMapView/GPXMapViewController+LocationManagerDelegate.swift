//
//  GPXMapViewController+LocationManagerDelegate.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 5/16/25.
//

import Cocoa
import MapKit
import MyLibrary

//extension GPXMapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        // 위치 한 번 받고 멈춤
//        locationManager.stopUpdatingLocation()
//
//        if bufferManager.sortedBuffers.isEmpty == true {
//            let region = MKCoordinateRegion(
//                center: location.coordinate,
//                latitudinalMeters: 50_000,
//                longitudinalMeters: 50_000
//            )
//            self.mapView.setRegion(region, animated: false)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("locationManager didFailWithError: \(error)")
//    }
//}

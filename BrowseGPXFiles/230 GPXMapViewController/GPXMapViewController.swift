//
//  GPXMapViewController.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 8/20/24.
//

import Cocoa
import MapKit
import MyLibrary

final class GPXMapViewController: NSViewController {

    let locationManager = CLLocationManager()
    let mapView = MKMapView()

    var initialClickLocation: NSPoint?
    var isDragging = false
    var tolerance: CGFloat = 5.0

    let bufferManager: GPXBufferManager

    init(_ bufferManager: GPXBufferManager) {
        self.bufferManager = bufferManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        addMapView()
        self.view.window?.makeFirstResponder(self) // 키 입력에 필요
        DispatchQueue.main.async {
            self.updateSubviews()
            self.zoomToFitAllOverlays()
        }
    }

    func addMapView() {
        mapView.frame = view.bounds

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            mapView.topAnchor.constraint(equalTo: view.topAnchor),
//            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func updateSubviews() {
        updateOverlays()
        //        sidebarController.updateItems()
        //        sidebarController.updateSelected()
        bufferManager.flushUpdated()
    }
}

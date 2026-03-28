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

//    let locationManager = CLLocationManager()

    let mapView = MKMapView()

    var startPoint: NSPoint?
    var isDragging = false
    var isSelectionMode: Bool = false
    var tolerance: CGFloat = 5.0
    var selectionLayer = CAShapeLayer()

    var contextPoint: NSPoint?

    let bufferManager: GPXBufferManager

    override var acceptsFirstResponder: Bool { true } // 키 입력에 필요

    init(_ bufferManager: GPXBufferManager) {
        self.bufferManager = bufferManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true

        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        addMapView()

//        앱 실행시 지도를 사용자 위치 중심으로 Zoom 해서 표시하려고 넣은 코드인데 불필요한 권한을 요청하는 것 같다. 안 쓰는 것으로;
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    func addMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        selectionLayer.fillColor = NSColor.systemBlue.withAlphaComponent(0.3).cgColor
        selectionLayer.strokeColor = NSColor.systemBlue.cgColor
        selectionLayer.lineWidth = 1.0
        selectionLayer.zPosition = 999
        view.layer?.addSublayer(selectionLayer)

        self.view.window?.makeFirstResponder(self) // 키 입력에 필요
    }
}

extension GPXMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            if let buffer = bufferManager.buffer(from: polyline) {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if buffer.isSelected {
                    renderer.strokeColor = .red
                } else {
                    renderer.strokeColor = .blue
                }
                renderer.lineWidth = 3.0
                return renderer
            }
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


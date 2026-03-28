//
//  PreviewViewController.swift
//  GPXPreviewExtension
//
//  Created by Kyuhyun Park on 3/17/26.
//

import Cocoa
import Quartz
import MapKit
import MyLibrary

// QuickLook 에선 네트웍을 쓰지 못하게 막혔다고 한다.
// 해서 MapView 배경 지도가 표시되지 않는다;

// 코드는 남겨놓고 프로젝트 빌드에서 제외해야겠다.

class PreviewViewController: NSViewController, QLPreviewingController {

    let mapView = MKMapView()

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        super.loadView()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /*
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?) async throws {
        // Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.

        // Perform any setup necessary in order to prepare the view.
        // Quick Look will display a loading spinner until this returns.
    }
    */

    func preparePreviewOfFile(at url: URL) async throws {
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        // Perform any setup necessary in order to prepare the view.
        // Quick Look will display a loading spinner until this returns.

        let data = try Data(contentsOf: url)
        let gpx = try GPXParser().parse(data: data)

        var polylines: [MKPolyline] = []
        for track in gpx.tracks {
            for segment in track.segments {
                let polyline = GPXUtility.makePolyline(from: segment)
                polylines.append(polyline)
            }
        }

        mapView.addOverlays(polylines)

        var zoomRect = MKMapRect.null
        for polyline in polylines {
            zoomRect = zoomRect.union(polyline.boundingMapRect)
        }
        if !zoomRect.isNull {
            Task {
                let padding: CGFloat = 10
                let edgePadding = NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
                mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
            }
        }
    }
}

extension PreviewViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 3.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


//
//  GPXMapViewController+Menu.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/13/26.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController {
    override func rightMouseDown(with event: NSEvent) {
        contextPoint = mapView.convert(event.locationInWindow, from: nil)

        let menu = NSMenu()
        menu.addItem(withTitle: "Show in Finder", action: #selector(showInFinder), keyEquivalent: "")
        NSMenu.popUpContextMenu(menu, with: event, for: mapView)
    }

    @IBAction func showInFinder(_ sender: Any) {
        guard let point = contextPoint else { return }
        let (mapPoint, tolerance) = mapPoint(at: point)
        if let url = bufferManager.nearestBuffer(at: mapPoint, with: tolerance)?.url {
            Finder.shared.open(url: url)
        }
    }
}

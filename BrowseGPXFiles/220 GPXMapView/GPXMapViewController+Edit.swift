//
//  GPXMapViewController+Edit.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/26/25.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController {

    @IBAction func undo(_ sender: Any?) {
        undoManager?.undo()
    }

    @IBAction  func redo(_ sender: Any?) {
        undoManager?.redo()
    }

    @IBAction func copy(_ sender: Any) {
        bufferManager.copyToClipboard()
    }

    @IBAction func paste(_ sender: Any) {
        bufferManager.pasteFromClipboard()
        bufferManager.zoomToFitAllBuffers()
//        viewState.zoomToFit = true
    }

    @IBAction func delete(_ sender: Any?) {
        bufferManager.removeSelectedBuffers()
    }

    @IBAction override func selectAll(_ sender: Any?) {
        bufferManager.selectAllBuffers()
    }
}

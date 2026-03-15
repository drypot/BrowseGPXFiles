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

    // NavigationSplitView -> List 에 Copy & Paste 코드 붙여놓는 것과 별도로
    // MapView 쪽에도 나름 같은 코드들 붙여놓는 것이 부작용이 덜했다.
    // 포커스가 어디 있는가에 따라 사용되는 코드가 달라진다.

    @IBAction func undo(_ sender: Any?) {
        undoManager?.undo()
    }

    @IBAction  func redo(_ sender: Any?) {
        undoManager?.redo()
    }

    @IBAction func cut(_ sender: Any) {
        bufferManager.cutToClipboard()
    }

    @IBAction func copy(_ sender: Any) {
        bufferManager.copyToClipboard()
    }

    @IBAction func paste(_ sender: Any) {
        bufferManager.pasteFromClipboard()
        bufferManager.zoomToAllBuffers()
    }

    @IBAction func delete(_ sender: Any?) {
        bufferManager.removeSelectedBuffers()
    }

    @IBAction override func selectAll(_ sender: Any?) {
        bufferManager.selectAllBuffers()
    }
}

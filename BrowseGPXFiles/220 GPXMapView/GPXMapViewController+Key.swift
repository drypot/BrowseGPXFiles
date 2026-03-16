//
//  GPXMapViewController+Key.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/26/25.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController {
    override func keyDown(with event: NSEvent) {

        // specialKey 는 macOS 13, 2022 이상에서만 지원한다고 한다.
        // 구 버전을 지원하려면 keyCode 를 써야하는데 버추얼키 정의 테이블이 없어서 숫자를 외워야 한다.

        switch event.specialKey {
        case .delete:
            bufferManager.removeSelectedBuffers()
        default:
            super.keyDown(with: event)
        }
    }
}

//
//  GPXBufferManager+UpdateLog.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import Foundation
import MapKit
import MyLibrary

extension GPXBufferManager {

    final class UpdateLog {
        enum MapViewUpdateCommand {
            case addBuffers([GPXBuffer])
            case removeBuffers([GPXBuffer])
            case updateBuffers([GPXBuffer])
        }

        var mapViewUpdateCommands: [MapViewUpdateCommand] = []

        func logAddBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.addBuffers(buffers))
        }

        func logRemoveBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.removeBuffers(buffers))
        }

        func logUpdateBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.updateBuffers(buffers))
        }

        func update(_ mapView: MKMapView) {
            for command in mapViewUpdateCommands {
                switch command {
                case .addBuffers(let buffers):
                    for buffer in buffers {
                        mapView.addOverlays(buffer.polylines)
                    }
                case .removeBuffers(let buffers):
                    for buffer in buffers {
                        mapView.removeOverlays(buffer.polylines)
                    }
                case .updateBuffers(let buffers):
                    for buffer in buffers {
                        mapView.removeOverlays(buffer.polylines)
                        mapView.addOverlays(buffer.polylines)
                    }
                }
            }
            mapViewUpdateCommands.removeAll()
        }
    }
}

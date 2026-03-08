//
//  GPXBufferManager+MapViewUpdater.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import Foundation
import MapKit
import MyLibrary

extension GPXBufferManager {

    final class MapViewUpdater {
        enum MapViewUpdateCommand {
            case addBuffers([GPXBuffer])
            case removeBuffers([GPXBuffer])
            case updateColor([GPXBuffer])
            case updateBuffers([GPXBuffer])
        }

        var mapViewUpdateCommands: [MapViewUpdateCommand] = []

        func queueAddBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.addBuffers(buffers))
        }

        func queueRemoveBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.removeBuffers(buffers))
        }

        func queueUpdateColor(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.updateColor(buffers))
        }

        func queueUpdateBuffers(_ buffers: [GPXBuffer]) {
            mapViewUpdateCommands.append(.updateBuffers(buffers))
        }

        func flush(to mapView: MKMapView) {
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
                case .updateColor(let buffers):
                    for buffer in buffers {
                        for polyline in buffer.polylines {
                            if let renderer = mapView.renderer(for: polyline) as? MKPolylineRenderer {
                                if buffer.isSelected {
                                    renderer.strokeColor = .red
                                } else {
                                    renderer.strokeColor = .blue
                                }
                            }
                        }
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

//
//  GPXSample.swift
//  ModelTests
//
//  Created by drypot on 2024-04-07.
//

import Foundation

let gpxSampleNoContent = """
"""

let gpxSampleBad = """
<trk>
  <name>Sample01</name>
  <trkseg>
    <trkpt lat="37.5323012" lon="127.0596635">
      <ele>15</ele>
      <time>2024-04-01T00:00:00Z</time>
    <!--</trkpt>-->
  </trkseg>
</trk>
"""

let gpxSampleNoTrack = """
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="texteditor" version="1.1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
</gpx>
"""

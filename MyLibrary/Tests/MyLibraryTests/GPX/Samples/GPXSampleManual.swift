//
//  GPXSampleManual.swift
//  ModelTests
//
//  Created by drypot on 2024-04-01.
//

let gpxSampleManual = """
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<gpx xmlns="http://www.topografix.com/GPX/1/1" creator="texteditor" version="1.1"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
  <metadata>
    <name>name1</name>
    <desc>desc1</desc>
  </metadata>
  <wpt lat="37.5458958" lon="127.0304489">
    <time>2024-04-01T00:57:37Z</time>
    <name>wp1name</name>
    <cmt>wp1cmt</cmt>
    <desc>wp1desc</desc>
    <sym>Flag, Blue</sym>
    <type>Waypoint</type>
  </wpt>
  <trk>
    <name>trk1name</name>
    <cmt>trk1cmt</cmt>
    <desc>trk1desc</desc>
    <trkseg>
      <trkpt lat="37.5323012" lon="127.0596635">
        <ele>15</ele>
        <time>2024-04-01T00:00:00Z</time>
      </trkpt>
      <trkpt lat="37.5338156" lon="127.056756">
        <ele>15</ele>
        <time>2024-04-01T00:04:51Z</time>
      </trkpt>
      <trkpt lat="37.5348451" lon="127.0529473">
        <ele>17</ele>
        <time>2024-04-01T00:10:46Z</time>
      </trkpt>
      <trkpt lat="37.5365211" lon="127.0469928">
        <ele>20</ele>
        <time>2024-04-01T00:20:10Z</time>
      </trkpt>
      <trkpt lat="37.5369805" lon="127.0454371">
        <ele>16</ele>
        <time>2024-04-01T00:22:22Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
"""

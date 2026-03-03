//
//  UTType.swift
//  GPXApp
//
//  Created by Kyuhyun Park on 8/20/24.
//

import UniformTypeIdentifiers

/*
    Project -> Target -> Info -> Document Types 에 가서 + 누르면 Info.plist 가 생성된다.
    Info.plist 소스로 열어서 복사해 넣는다.

    <dict>
        <key>CFBundleDocumentTypes</key>
        <array>
            <dict>
                <key>CFBundleTypeName</key>
                <string>GPS Exchange Format (GPX)</string>
                <key>CFBundleTypeRole</key>
                <string>Viewer</string>
                <key>LSHandlerRank</key>
                <string>Alternate</string>
                <key>LSItemContentTypes</key>
                <array>
                    <string>com.topografix.gpx</string>
                </array>
                <key>NSDocumentClass</key>
                <string>$(PRODUCT_MODULE_NAME).Document</string>
            </dict>
        </array>
        <key>UTImportedTypeDeclarations</key>
        <array>
            <dict>
                <key>UTTypeConformsTo</key>
                <array>
                    <string>public.xml</string>
                </array>
                <key>UTTypeDescription</key>
                <string>GPS Exchange Format (GPX)</string>
                <key>UTTypeIcons</key>
                <dict/>
                <key>UTTypeIdentifier</key>
                <string>com.topografix.gpx</string>
                <key>UTTypeTagSpecification</key>
                <dict>
                    <key>public.filename-extension</key>
                    <array>
                        <string>gpx</string>
                    </array>
                    <key>public.mime-type</key>
                    <array>
                        <string>application/gpx+xml</string>
                    </array>
                </dict>
            </dict>
        </array>
    </dict>
*/

extension UTType {
    //static let browseGPXFiles: UTType = UTType(exportedAs: "com.drypot.browsegpxfiles")
    public static let gpx: UTType = UTType(importedAs: "com.topografix.gpx")
}

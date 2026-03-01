//
//  GPXBufferBrowser.swift
//  BrowseTextFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import MyLibrary

struct GPXBufferBrowser: View {
    @Environment(SettingsData.self) var settings

    @State private var root: URL?

    @State private var fileListManager = FileListManager()
    @State private var selectedFile: URL?

    @State private var textBufferManager = TextBufferManager()
    @State private var selectedTextBuffer: TextBuffer?

    var body: some View {
        if let root {
            NavigationSplitView {
                List(fileListManager.files, id: \.self, selection: $selectedFile) { file in
                    NavigationLink(file.lastPathComponent, value: file)
                }
                .navigationTitle(root.lastPathComponent) // 왜 안 보일까?
            } detail: {
                TabView(selection: $selectedTextBuffer) {
                    ForEach(textBufferManager.files) { buffer in
                        @Bindable var buffer = buffer
                        TextEditor(text: $buffer.text)
                            .font(.custom(settings.fontName, size: settings.fontSize))
                            .lineSpacing(settings.lineSpacing)
                            .tabItem {
                                Text(buffer.name)
                            }
                            .tag(buffer)
                    }
                }
                .padding()

            }
//            .toolbarBackground(.hidden) // macOS 26, 툴바 구분선이 나왔다 사라졌다 한다, 강제로 감추는 옵션.
            .onChange(of: selectedFile) {
                openFile()
            }
        } else {
            Button("Open Folder") {
                openFolder()
            }
            Button("Open Last Folder") {
                openLastFolder()
            }
        }
    }

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            openFolder(from: url)
            BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
        }
    }

    func openFolder(from url: URL) {
        root = url
        updateFiles()
    }

    func openLastFolder() {
        if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
            openFolder(from: url)
        }
    }

    func updateFiles() {
        do {
            guard let root else { return }
            guard root.startAccessingSecurityScopedResource() else { return }
            defer { root.stopAccessingSecurityScopedResource() }
            try fileListManager.update(from: root)
            selectedFile = nil
        } catch {
            print("file list update failed: \(error.localizedDescription)")
        }
    }

    func openFile() {
        do {
            guard let root else { return }
            guard let selectedFileURL = selectedFile else { return }
            if let file = textBufferManager.file(for: selectedFileURL) {
                selectedTextBuffer = file
            } else {
                guard root.startAccessingSecurityScopedResource() else { return }
                defer { root.stopAccessingSecurityScopedResource() }
                selectedTextBuffer = try textBufferManager.addFile(from: selectedFileURL)
            }
        } catch {
            print("file open failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBufferBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}

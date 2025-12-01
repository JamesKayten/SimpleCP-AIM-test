//
//  SimpleCPApp.swift
//  SimpleCP
//
//  Created by SimpleCP
//

import SwiftUI

@main
struct SimpleCPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clipboardManager = ClipboardManager()
    @StateObject private var backendService = BackendService()
    @State private var showSettings = false

    init() {
        // Note: Can't access @StateObject in init
        // The backendService will be shared via AppDelegate after first body evaluation
    }

    var body: some Scene {
        MenuBarExtra("📋 SimpleCP", systemImage: "doc.on.clipboard") {
            ContentView()
                .environmentObject(clipboardManager)
                .environmentObject(backendService)
                .frame(width: 600, height: 400)
                .task {
                    // Set up shared reference for cleanup
                    AppDelegate.sharedBackendService = backendService

                    // Start backend on app launch
                    if !backendService.isRunning {
                        backendService.startBackend()
                    }
                }
        }
        .menuBarExtraStyle(.window)

        // Settings window
        Window("Settings", id: "settings") {
            SettingsWindow()
                .environmentObject(clipboardManager)
                .environmentObject(backendService)
                .frame(width: 500, height: 400)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

}

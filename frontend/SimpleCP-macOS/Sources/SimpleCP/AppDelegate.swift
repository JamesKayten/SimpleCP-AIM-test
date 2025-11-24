//
//  AppDelegate.swift
//  SimpleCP
//
//  Handles application lifecycle events
//

import SwiftUI
import os.log

class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "com.simplecp.app", category: "lifecycle")

    // Shared reference to backend service for cleanup
    static weak var sharedBackendService: BackendService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        logger.info("🚀 Application finished launching")
    }

    func applicationWillTerminate(_ notification: Notification) {
        logger.info("🛑 Application will terminate - cleaning up backend...")

        // Stop the backend process
        if let backendService = AppDelegate.sharedBackendService {
            backendService.stopBackend()

            // Give it a moment to clean up
            Thread.sleep(forTimeInterval: 0.5)
        }

        logger.info("✅ Cleanup complete")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // For menu bar apps, don't terminate when windows close
        return false
    }
}

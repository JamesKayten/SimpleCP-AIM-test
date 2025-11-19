import SwiftUI

@main
struct SimpleCPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and make it a menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Initialize status bar
        statusBar = StatusBarController()
    }
}
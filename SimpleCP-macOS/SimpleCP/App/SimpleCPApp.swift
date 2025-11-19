import SwiftUI

@main
struct SimpleCPApp: App {
    var body: some Scene {
        MenuBarExtra("SimpleCP", systemImage: "clipboard") {
            ContentView()
                .frame(width: 600, height: 400)
        }
        .menuBarExtraStyle(.window)
    }
}
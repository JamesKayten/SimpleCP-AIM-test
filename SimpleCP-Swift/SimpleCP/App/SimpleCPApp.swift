import SwiftUI

@main
struct SimpleCPApp: App {
    @StateObject private var apiClient = APIClient()
    @StateObject private var appState = AppState()

    @StateObject private var clipboardService: ClipboardService
    @StateObject private var snippetService: SnippetService
    @StateObject private var searchService: SearchService

    init() {
        let apiClient = APIClient()
        let appState = AppState()

        _apiClient = StateObject(wrappedValue: apiClient)
        _appState = StateObject(wrappedValue: appState)
        _clipboardService = StateObject(wrappedValue: ClipboardService(apiClient: apiClient, appState: appState))
        _snippetService = StateObject(wrappedValue: SnippetService(apiClient: apiClient, appState: appState))
        _searchService = StateObject(wrappedValue: SearchService(apiClient: apiClient, appState: appState))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiClient)
                .environmentObject(appState)
                .environmentObject(clipboardService)
                .environmentObject(snippetService)
                .environmentObject(searchService)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

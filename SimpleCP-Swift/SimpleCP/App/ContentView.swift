import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var clipboardService: ClipboardService
    @EnvironmentObject var snippetService: SnippetService
    @EnvironmentObject var searchService: SearchService

    var body: some View {
        VStack(spacing: 0) {
            // Header with title, search, and settings
            HeaderView()

            // Control bar with action buttons
            ControlBar()

            Divider()

            // Main two-column layout
            HStack(spacing: 0) {
                // Left column: History
                HistoryColumnView()
                    .frame(maxWidth: .infinity)

                Divider()

                // Right column: Snippets
                SnippetsColumnView()
                    .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $appState.showSaveSnippetDialog) {
            if let item = appState.selectedHistoryItem {
                SaveSnippetDialog(clipboardItem: item)
            }
        }
        .task {
            await loadInitialData()
        }
    }

    private func loadInitialData() async {
        await clipboardService.loadHistory()
        await clipboardService.loadHistoryFolders()
        await snippetService.loadSnippets()
        await snippetService.loadFolders()

        // Start auto-refresh for history
        clipboardService.startAutoRefresh()
    }
}

import SwiftUI

struct ControlBar: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var clipboardService: ClipboardService
    @State private var showManageDialog = false

    var body: some View {
        HStack(spacing: 16) {
            // Save as Snippet button
            Button(action: {
                if let selected = appState.selectedHistoryItem {
                    appState.showSaveSnippetDialog = true
                }
            }) {
                Label("Save as Snippet", systemImage: "square.and.arrow.down")
            }
            .disabled(appState.selectedHistoryItem == nil)

            Spacer()

            // Manage buttons
            Button(action: {
                showManageDialog = true
            }) {
                Label("Manage", systemImage: "folder")
            }

            // Refresh button
            Button(action: {
                Task {
                    await clipboardService.refresh()
                }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }

            // Clear History button
            Button(role: .destructive, action: {
                Task {
                    await clipboardService.clearHistory()
                }
            }) {
                Label("Clear History", systemImage: "trash")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.05))
        .sheet(isPresented: $showManageDialog) {
            ManageFoldersView()
        }
    }
}

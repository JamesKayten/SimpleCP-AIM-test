import SwiftUI

struct HistoryColumnView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var clipboardService: ClipboardService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Header
            Text("Recent Clipboard")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))

            Divider()

            // History Items List
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(appState.displayedHistoryItems) { item in
                        HistoryItemView(item: item)
                            .background(
                                appState.selectedHistoryItem?.clipId == item.clipId ?
                                Color.blue.opacity(0.2) : Color.clear
                            )
                            .onTapGesture {
                                appState.selectedHistoryItem = item
                            }
                    }
                }
            }

            // History Folders Section
            if !appState.historyFolders.isEmpty {
                Divider()

                Text("History Archives")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)

                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(appState.historyFolders) { folder in
                            HistoryFolderView(folder: folder)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxHeight: 150)
            }

            // Loading/Error States
            if appState.isLoading {
                LoadingView()
            }

            if let error = appState.errorMessage {
                ErrorView(message: error)
            }
        }
    }
}

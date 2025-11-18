import Foundation

// MARK: - Clipboard Service
@MainActor
class ClipboardService: ObservableObject {
    private let apiClient: APIClient
    private let appState: AppState

    init(apiClient: APIClient, appState: AppState) {
        self.apiClient = apiClient
        self.appState = appState
    }

    // MARK: - History Operations
    func loadHistory() async {
        appState.isLoading = true
        defer { appState.isLoading = false }

        do {
            appState.historyItems = try await apiClient.getHistoryRecent()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func loadHistoryFolders() async {
        do {
            appState.historyFolders = try await apiClient.getHistoryFolders()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func deleteHistoryItem(_ item: ClipboardItem) async {
        do {
            try await apiClient.deleteHistoryItem(id: item.clipId)
            await loadHistory()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func clearHistory() async {
        do {
            try await apiClient.clearHistory()
            appState.historyItems = []
            appState.historyFolders = []
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func copyToClipboard(_ item: ClipboardItem) async {
        do {
            try await apiClient.copyToClipboard(itemId: item.clipId)
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    // MARK: - Refresh
    func refresh() async {
        await loadHistory()
        await loadHistoryFolders()
    }

    // MARK: - Auto-refresh
    func startAutoRefresh(interval: TimeInterval = 2.0) {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.loadHistory()
            }
        }
    }
}

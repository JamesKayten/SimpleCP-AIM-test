import Foundation

// MARK: - Search Service
@MainActor
class SearchService: ObservableObject {
    private let apiClient: APIClient
    private let appState: AppState

    init(apiClient: APIClient, appState: AppState) {
        self.apiClient = apiClient
        self.appState = appState
    }

    func search(query: String) async {
        guard !query.isEmpty else {
            appState.clearSearch()
            return
        }

        appState.isLoading = true
        defer { appState.isLoading = false }

        do {
            let results = try await apiClient.search(query: query)
            appState.searchResults = results
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func clearSearch() {
        appState.clearSearch()
    }
}

import Foundation
import SwiftUI

// MARK: - App State Management
@MainActor
class AppState: ObservableObject {
    @Published var historyItems: [ClipboardItem] = []
    @Published var historyFolders: [HistoryFolder] = []
    @Published var snippetFolders: [String] = []
    @Published var snippetsByFolder: [String: [ClipboardItem]] = [:]
    @Published var searchQuery: String = ""
    @Published var searchResults: SearchResults?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedHistoryItem: ClipboardItem?
    @Published var selectedSnippetItem: ClipboardItem?
    @Published var showSaveSnippetDialog: Bool = false
    @Published var stats: Stats?

    var isSearching: Bool {
        !searchQuery.isEmpty
    }

    var displayedHistoryItems: [ClipboardItem] {
        if isSearching, let results = searchResults {
            return results.historyResults
        }
        return historyItems
    }

    var displayedSnippets: [String: [ClipboardItem]] {
        if isSearching, let results = searchResults {
            var grouped: [String: [ClipboardItem]] = [:]
            for item in results.snippetResults {
                let folder = item.folderPath ?? "Uncategorized"
                grouped[folder, default: []].append(item)
            }
            return grouped
        }
        return snippetsByFolder
    }

    func clearError() {
        errorMessage = nil
    }

    func setError(_ error: Error) {
        errorMessage = error.localizedDescription
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = nil
    }
}

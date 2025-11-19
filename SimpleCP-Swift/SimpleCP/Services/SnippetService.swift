import Foundation

// MARK: - Snippet Service
@MainActor
class SnippetService: ObservableObject {
    private let apiClient: APIClient
    private let appState: AppState

    init(apiClient: APIClient, appState: AppState) {
        self.apiClient = apiClient
        self.appState = appState
    }

    // MARK: - Snippet Operations
    func loadSnippets() async {
        appState.isLoading = true
        defer { appState.isLoading = false }

        do {
            appState.snippetsByFolder = try await apiClient.getSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func loadFolders() async {
        do {
            appState.snippetFolders = try await apiClient.getSnippetFolders()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func createSnippet(
        content: String? = nil,
        fromClipId: String? = nil,
        name: String,
        folder: String,
        tags: [String] = []
    ) async {
        let request = CreateSnippetRequest(
            content: content,
            fromClipId: fromClipId,
            name: name,
            folder: folder,
            tags: tags
        )

        do {
            _ = try await apiClient.createSnippet(request: request)
            await loadSnippets()
            await loadFolders()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func updateSnippet(
        folder: String,
        item: ClipboardItem,
        name: String?,
        tags: [String]?
    ) async {
        let request = UpdateSnippetRequest(name: name, tags: tags)

        do {
            _ = try await apiClient.updateSnippet(folder: folder, itemId: item.clipId, request: request)
            await loadSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func deleteSnippet(folder: String, item: ClipboardItem) async {
        do {
            try await apiClient.deleteSnippet(folder: folder, itemId: item.clipId)
            await loadSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func moveSnippet(item: ClipboardItem, from sourceFolder: String, to targetFolder: String) async {
        do {
            try await apiClient.moveSnippet(folder: sourceFolder, itemId: item.clipId, newFolder: targetFolder)
            await loadSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    // MARK: - Folder Operations
    func createFolder(name: String) async {
        do {
            try await apiClient.createFolder(name: name)
            await loadFolders()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func renameFolder(oldName: String, newName: String) async {
        do {
            try await apiClient.renameFolder(oldName: oldName, newName: newName)
            await loadFolders()
            await loadSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }

    func deleteFolder(name: String) async {
        do {
            try await apiClient.deleteFolder(name: name)
            await loadFolders()
            await loadSnippets()
            appState.clearError()
        } catch {
            appState.setError(error)
        }
    }
}

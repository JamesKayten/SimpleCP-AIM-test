//
//  ClipboardManager.swift
//  SimpleCP
//
//  Created by SimpleCP
//

import Foundation
import AppKit
import Combine

class ClipboardManager: ObservableObject {
    @Published var clipHistory: [ClipItem] = []
    @Published var snippets: [Snippet] = []
    @Published var folders: [SnippetFolder] = []
    @Published var currentClipboard: String = ""

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let maxHistorySize: Int = 50
    private let userDefaults = UserDefaults.standard

    // Storage keys
    private let historyKey = "clipboardHistory"
    private let snippetsKey = "savedSnippets"
    private let foldersKey = "snippetFolders"

    init() {
        loadData()
        startMonitoring()
    }

    // MARK: - Clipboard Monitoring

    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }

        lastChangeCount = pasteboard.changeCount

        if let content = pasteboard.string(forType: .string), !content.isEmpty {
            currentClipboard = content
            addToHistory(content: content)
        }
    }

    // MARK: - History Management

    func addToHistory(content: String) {
        // Avoid duplicates
        if let existingIndex = clipHistory.firstIndex(where: { $0.content == content }) {
            // Move to top if it already exists
            let item = clipHistory.remove(at: existingIndex)
            clipHistory.insert(item, at: 0)
        } else {
            // Add new item
            let contentType = detectContentType(content)
            let newItem = ClipItem(content: content, contentType: contentType)
            clipHistory.insert(newItem, at: 0)

            // Limit history size
            if clipHistory.count > maxHistorySize {
                clipHistory = Array(clipHistory.prefix(maxHistorySize))
            }
        }

        saveHistory()
    }

    func removeFromHistory(item: ClipItem) {
        clipHistory.removeAll { $0.id == item.id }
        saveHistory()
    }

    func clearHistory() {
        clipHistory.removeAll()
        saveHistory()
    }

    func copyToClipboard(_ content: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(content, forType: .string)
        lastChangeCount = pasteboard.changeCount
        currentClipboard = content
    }

    private func detectContentType(_ content: String) -> ClipItem.ContentType {
        // Simple content type detection
        if content.hasPrefix("http://") || content.hasPrefix("https://") {
            return .url
        } else if content.contains("@") && content.contains(".") && !content.contains(" ") {
            return .email
        } else if content.contains("{") || content.contains("func ") || content.contains("import ") {
            return .code
        }
        return .text
    }

    // MARK: - Snippet Management

    func saveAsSnippet(name: String, content: String, folderId: UUID?, tags: [String] = []) {
        let snippet = Snippet(
            name: name,
            content: content,
            tags: tags,
            folderId: folderId
        )
        snippets.append(snippet)
        saveSnippets()
    }

    func updateSnippet(_ snippet: Snippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index] = snippet
            saveSnippets()
        }
    }

    func deleteSnippet(_ snippet: Snippet) {
        snippets.removeAll { $0.id == snippet.id }
        saveSnippets()
    }

    func getSnippets(for folderId: UUID) -> [Snippet] {
        snippets.filter { $0.folderId == folderId }
    }

    func suggestSnippetName(for content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstLine = trimmed.components(separatedBy: .newlines).first ?? ""

        if firstLine.isEmpty {
            return "Untitled Snippet"
        }

        // Take first 50 characters or first line
        let preview = String(firstLine.prefix(50))
        return preview
    }

    // MARK: - Folder Management

    func createFolder(name: String, icon: String = "📁") {
        let order = folders.count
        let folder = SnippetFolder(name: name, icon: icon, order: order)
        folders.append(folder)
        saveFolders()
    }

    func updateFolder(_ folder: SnippetFolder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
            saveFolders()
        }
    }

    func deleteFolder(_ folder: SnippetFolder) {
        // Remove snippets in this folder
        snippets.removeAll { $0.folderId == folder.id }
        folders.removeAll { $0.id == folder.id }
        saveFolders()
        saveSnippets()
    }

    func toggleFolderExpansion(_ folderId: UUID) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            folders[index].toggleExpanded()
            saveFolders()
        }
    }

    // MARK: - Search

    func search(query: String) -> (clips: [ClipItem], snippets: [Snippet]) {
        let lowercaseQuery = query.lowercased()

        let filteredClips = clipHistory.filter { clip in
            clip.content.lowercased().contains(lowercaseQuery)
        }

        let filteredSnippets = snippets.filter { snippet in
            snippet.name.lowercased().contains(lowercaseQuery) ||
            snippet.content.lowercased().contains(lowercaseQuery) ||
            snippet.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }

        return (filteredClips, filteredSnippets)
    }

    // MARK: - Persistence

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(clipHistory) {
            userDefaults.set(encoded, forKey: historyKey)
        }
    }

    private func saveSnippets() {
        if let encoded = try? JSONEncoder().encode(snippets) {
            userDefaults.set(encoded, forKey: snippetsKey)
        }
    }

    private func saveFolders() {
        if let encoded = try? JSONEncoder().encode(folders) {
            userDefaults.set(encoded, forKey: foldersKey)
        }
    }

    private func loadData() {
        // Load history
        if let data = userDefaults.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ClipItem].self, from: data) {
            clipHistory = decoded
        }

        // Load snippets
        if let data = userDefaults.data(forKey: snippetsKey),
           let decoded = try? JSONDecoder().decode([Snippet].self, from: data) {
            snippets = decoded
        }

        // Load folders
        if let data = userDefaults.data(forKey: foldersKey),
           let decoded = try? JSONDecoder().decode([SnippetFolder].self, from: data) {
            folders = decoded
        } else {
            // Create default folders if none exist
            folders = SnippetFolder.defaultFolders()
            saveFolders()
        }

        // Get current clipboard
        if let content = NSPasteboard.general.string(forType: .string) {
            currentClipboard = content
        }
    }

    deinit {
        stopMonitoring()
    }
}

import SwiftUI

struct ContentView: View {
    @StateObject private var apiClient = APIClient()
    @State private var historyItems: [ClipboardItem] = []
    @State private var searchQuery: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedItem: ClipboardItem?
    @State private var showingSnippetSheet: Bool = false
    @State private var snippetName: String = ""
    @State private var snippetFolder: String = "Default"

    var filteredItems: [ClipboardItem] {
        if searchQuery.isEmpty {
            return historyItems
        }
        return historyItems.filter { item in
            item.content.localizedCaseInsensitiveContains(searchQuery) ||
            (item.name?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Connection Status
                HStack {
                    Circle()
                        .fill(apiClient.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(apiClient.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                    Spacer()
                    Button("Refresh") {
                        Task { await loadHistory() }
                    }
                }
                .padding()

                // Search Bar
                TextField("Search clipboard history...", text: $searchQuery)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                // History List
                List(filteredItems) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        if let name = item.name {
                            Text(name)
                                .font(.headline)
                        }
                        Text(item.content)
                            .lineLimit(2)
                            .font(.body)
                        Text(formatDate(item.timestamp))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Button("Copy") {
                                copyToClipboard(item.content)
                            }
                            .buttonStyle(.bordered)

                            Button("Save as Snippet") {
                                selectedItem = item
                                showingSnippetSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("SimpleCP")
            .onAppear {
                Task {
                    _ = await apiClient.testConnection()
                    await loadHistory()
                }
            }
        }
        .sheet(isPresented: $showingSnippetSheet) {
            snippetSheet
        }
    }

    private var snippetSheet: some View {
        VStack(spacing: 20) {
            Text("Save as Snippet")
                .font(.headline)

            TextField("Snippet Name", text: $snippetName)
                .textFieldStyle(.roundedBorder)

            TextField("Folder", text: $snippetFolder)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") {
                    showingSnippetSheet = false
                    snippetName = ""
                }
                .buttonStyle(.bordered)

                Button("Save") {
                    Task { await saveSnippet() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300, height: 200)
    }

    private func loadHistory() async {
        isLoading = true
        do {
            historyItems = try await apiClient.fetchHistory(limit: 100)
        } catch {
            print("Failed to load history: \(error)")
        }
        isLoading = false
    }

    private func saveSnippet() async {
        guard let item = selectedItem else { return }

        let request = CreateSnippetRequest(
            clipId: item.id,
            content: nil,
            name: snippetName.isEmpty ? nil : snippetName,
            folder: snippetFolder.isEmpty ? nil : snippetFolder,
            tags: nil
        )

        do {
            _ = try await apiClient.createSnippet(request: request)
            showingSnippetSheet = false
            snippetName = ""
        } catch {
            print("Failed to save snippet: \(error)")
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func formatDate(_ timestamp: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: timestamp) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return timestamp
    }
}

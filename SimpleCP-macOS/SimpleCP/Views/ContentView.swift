import SwiftUI

struct ContentView: View {
    @StateObject private var clipboardService = ClipboardService()
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Combined Search/Control Bar
            VStack(spacing: 8) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search clips and snippets...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)

                // Control Bar
                HStack(spacing: 12) {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Create Folder")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "folder")
                            Text("Manage Folders")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Spacer()

                    Button(action: clearHistory) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Clear History")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button(action: refreshData) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(12)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // Two-Column Content
            HStack(spacing: 0) {
                // Left Column - Recent Clips
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("RECENT CLIPS")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))

                    // Content
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(Array(clipboardService.historyItems.enumerated()), id: \.element.id) { index, item in
                                RecentClipRow(number: index + 1, item: item)
                                    .onTapGesture {
                                        Task {
                                            await clipboardService.copyItem(item)
                                        }
                                    }
                            }

                            // History folder ranges
                            if clipboardService.historyItems.count >= 10 {
                                HistoryFolderRanges()
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .frame(maxWidth: .infinity)

                Divider()

                // Right Column - Saved Snippets
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Image(systemName: "folder")
                        Text("SAVED SNIPPETS")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))

                    // Content
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(clipboardService.snippetFolders) { folder in
                                SnippetFolderRow(folder: folder)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .environmentObject(clipboardService)
        .onAppear {
            refreshData()
        }
    }

    private func refreshData() {
        Task {
            await clipboardService.fetchHistory()
            await clipboardService.fetchSnippets()
        }
    }

    private func clearHistory() {
        // TODO: Implement clear history
    }
}

struct RecentClipRow: View {
    let number: Int
    let item: ClipboardItem
    @EnvironmentObject var clipboardService: ClipboardService

    var body: some View {
        HStack(spacing: 8) {
            Text("\(number).")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)

            Text(item.preview)
                .font(.system(.body, design: .default))
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            // Add hover effect
        }
        .contextMenu {
            Button("Copy") {
                Task { await clipboardService.copyItem(item) }
            }
            Button("Save as Snippet") {
                // TODO: Save as snippet
            }
        }
    }
}

struct HistoryFolderRanges: View {
    var body: some View {
        VStack(spacing: 2) {
            Divider()
                .padding(.vertical, 4)

            ForEach([(11, 20), (21, 30), (31, 40), (41, 50)], id: \.0) { range in
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                    Text("\(range.0) - \(range.1)")
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    // TODO: Show range items
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
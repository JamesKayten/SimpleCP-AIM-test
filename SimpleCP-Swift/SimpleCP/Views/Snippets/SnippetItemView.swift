import SwiftUI

struct SnippetItemView: View {
    let snippet: ClipboardItem
    let folderName: String

    @EnvironmentObject var clipboardService: ClipboardService
    @EnvironmentObject var snippetService: SnippetService
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.orange)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    if let name = snippet.snippetName {
                        Text(name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    Text(snippet.previewText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()
            }

            // Tags if available
            if !snippet.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(snippet.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            appState.selectedSnippetItem?.clipId == snippet.clipId ?
            Color.green.opacity(0.2) : Color.clear
        )
        .cornerRadius(4)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                Task {
                    await clipboardService.copyToClipboard(snippet)
                }
            }) {
                Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
            }

            Divider()

            Button(role: .destructive, action: {
                Task {
                    await snippetService.deleteSnippet(folder: folderName, item: snippet)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .onTapGesture {
            appState.selectedSnippetItem = snippet
        }
        .onTapGesture(count: 2) {
            Task {
                await clipboardService.copyToClipboard(snippet)
            }
        }
    }
}

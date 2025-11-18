import SwiftUI

struct HistoryItemView: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardService: ClipboardService
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Content type indicator
                Image(systemName: contentTypeIcon)
                    .foregroundColor(contentTypeColor)
                    .frame(width: 20)

                // Preview text
                Text(item.displayString)
                    .lineLimit(2)
                    .font(.body)

                Spacer()

                // Timestamp
                Text(item.formattedTimestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Source app if available
            if let sourceApp = item.sourceApp {
                Text("From: \(sourceApp)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                Task {
                    await clipboardService.copyToClipboard(item)
                }
            }) {
                Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
            }

            Button(action: {
                appState.selectedHistoryItem = item
                appState.showSaveSnippetDialog = true
            }) {
                Label("Save as Snippet", systemImage: "square.and.arrow.down")
            }

            Divider()

            Button(role: .destructive, action: {
                Task {
                    await clipboardService.deleteHistoryItem(item)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .onTapGesture(count: 2) {
            Task {
                await clipboardService.copyToClipboard(item)
            }
        }
    }

    private var contentTypeIcon: String {
        switch item.contentType {
        case "url": return "link"
        case "email": return "envelope"
        case "code": return "chevron.left.forwardslash.chevron.right"
        default: return "doc.text"
        }
    }

    private var contentTypeColor: Color {
        switch item.contentType {
        case "url": return .blue
        case "email": return .green
        case "code": return .purple
        default: return .primary
        }
    }
}

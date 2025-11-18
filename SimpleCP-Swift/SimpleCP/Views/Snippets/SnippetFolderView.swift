import SwiftUI

struct SnippetFolderView: View {
    let folderName: String
    let snippets: [ClipboardItem]
    let isExpanded: Bool
    let onToggle: () -> Void

    @EnvironmentObject var snippetService: SnippetService

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Folder header
            HStack {
                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .foregroundColor(.green)

                Text(folderName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(snippets.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
            .onTapGesture {
                withAnimation {
                    onToggle()
                }
            }
            .contextMenu {
                Button(action: {
                    // Rename folder
                }) {
                    Label("Rename Folder", systemImage: "pencil")
                }

                Button(role: .destructive, action: {
                    Task {
                        await snippetService.deleteFolder(name: folderName)
                    }
                }) {
                    Label("Delete Folder", systemImage: "trash")
                }
            }

            // Folder contents (when expanded)
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(snippets) { snippet in
                        SnippetItemView(snippet: snippet, folderName: folderName)
                    }
                }
                .padding(.leading, 16)
            }
        }
    }
}

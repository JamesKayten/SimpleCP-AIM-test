import SwiftUI

struct SaveSnippetDialog: View {
    let clipboardItem: ClipboardItem

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var snippetService: SnippetService

    @State private var snippetName = ""
    @State private var selectedFolder = ""
    @State private var showNewFolder = false
    @State private var newFolderName = ""
    @State private var tagsText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Save as Snippet")
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            // Content preview
            GroupBox("Content Preview") {
                ScrollView {
                    Text(clipboardItem.content)
                        .textSelection(.enabled)
                        .font(.body)
                }
                .frame(height: 120)
            }

            // Snippet name
            VStack(alignment: .leading, spacing: 4) {
                Text("Snippet Name")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("Enter snippet name", text: $snippetName)
                    .textFieldStyle(.roundedBorder)
            }

            // Folder selection
            VStack(alignment: .leading, spacing: 4) {
                Text("Folder")
                    .font(.subheadline)
                    .fontWeight(.medium)

                if !showNewFolder {
                    Picker("Select folder", selection: $selectedFolder) {
                        ForEach(appState.snippetFolders, id: \.self) { folder in
                            Text(folder).tag(folder)
                        }
                    }
                    .pickerStyle(.menu)

                    Button(action: {
                        showNewFolder = true
                    }) {
                        Label("Create New Folder", systemImage: "folder.badge.plus")
                            .font(.caption)
                    }
                } else {
                    HStack {
                        TextField("New folder name", text: $newFolderName)
                            .textFieldStyle(.roundedBorder)

                        Button(action: {
                            showNewFolder = false
                            newFolderName = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Tags
            VStack(alignment: .leading, spacing: 4) {
                Text("Tags (optional, comma-separated)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("e.g., code, python, utils", text: $tagsText)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            // Action buttons
            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save Snippet") {
                    saveSnippet()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(snippetName.isEmpty || (selectedFolder.isEmpty && newFolderName.isEmpty))
            }
        }
        .padding()
        .frame(width: 500, height: 550)
        .onAppear {
            snippetName = suggestName()
            if !appState.snippetFolders.isEmpty {
                selectedFolder = appState.snippetFolders[0]
            }
        }
    }

    private func suggestName() -> String {
        let content = clipboardItem.content
        let maxLength = 50

        // Use first line or first 50 chars
        let firstLine = content.components(separatedBy: .newlines).first ?? content
        if firstLine.count <= maxLength {
            return firstLine
        }
        return String(firstLine.prefix(maxLength)) + "..."
    }

    private func saveSnippet() {
        let folder = showNewFolder ? newFolderName : selectedFolder
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        Task {
            if showNewFolder {
                await snippetService.createFolder(name: newFolderName)
            }

            await snippetService.createSnippet(
                fromClipId: clipboardItem.clipId,
                name: snippetName,
                folder: folder,
                tags: tags
            )

            dismiss()
        }
    }
}

import SwiftUI

struct ManageFoldersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var snippetService: SnippetService

    @State private var newFolderName = ""
    @State private var selectedFolder: String?
    @State private var renameFolderName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Manage Snippet Folders")
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            // Folder list
            GroupBox("Existing Folders") {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(appState.snippetFolders, id: \.self) { folder in
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(.blue)

                                Text(folder)

                                Spacer()

                                Text("\(appState.snippetsByFolder[folder]?.count ?? 0) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Button(role: .destructive, action: {
                                    Task {
                                        await snippetService.deleteFolder(name: folder)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .frame(height: 200)
            }

            // Create new folder
            GroupBox("Create New Folder") {
                HStack {
                    TextField("Folder name", text: $newFolderName)
                        .textFieldStyle(.roundedBorder)

                    Button("Create") {
                        createFolder()
                    }
                    .disabled(newFolderName.isEmpty)
                }
            }

            Spacer()

            // Close button
            HStack {
                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 500, height: 450)
    }

    private func createFolder() {
        Task {
            await snippetService.createFolder(name: newFolderName)
            newFolderName = ""
        }
    }
}

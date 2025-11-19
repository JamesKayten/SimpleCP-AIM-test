import SwiftUI

struct SnippetsColumnView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var snippetService: SnippetService
    @State private var expandedFolders: Set<String> = []
    @State private var showCreateFolder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Header
            HStack {
                Text("Snippets")
                    .font(.headline)

                Spacer()

                Button(action: {
                    showCreateFolder = true
                }) {
                    Image(systemName: "folder.badge.plus")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.green.opacity(0.1))

            Divider()

            // Snippets by Folder
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(sortedFolders, id: \.self) { folderName in
                        SnippetFolderView(
                            folderName: folderName,
                            snippets: appState.displayedSnippets[folderName] ?? [],
                            isExpanded: expandedFolders.contains(folderName)
                        ) {
                            toggleFolder(folderName)
                        }
                    }
                }
                .padding()
            }

            // Loading/Error States
            if appState.isLoading {
                LoadingView()
            }

            if let error = appState.errorMessage {
                ErrorView(message: error)
            }
        }
        .sheet(isPresented: $showCreateFolder) {
            CreateFolderDialog()
        }
    }

    private var sortedFolders: [String] {
        appState.displayedSnippets.keys.sorted()
    }

    private func toggleFolder(_ folderName: String) {
        if expandedFolders.contains(folderName) {
            expandedFolders.remove(folderName)
        } else {
            expandedFolders.insert(folderName)
        }
    }
}

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var searchService: SearchService
    @State private var showSettings = false

    var body: some View {
        HStack {
            // App Title
            Text("SimpleCP")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search clipboard and snippets...", text: $appState.searchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: appState.searchQuery) { newValue in
                        Task {
                            await searchService.search(query: newValue)
                        }
                    }

                if !appState.searchQuery.isEmpty {
                    Button(action: {
                        searchService.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .frame(maxWidth: 400)

            Spacer()

            // Settings Button
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showSettings) {
                SettingsWindow()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

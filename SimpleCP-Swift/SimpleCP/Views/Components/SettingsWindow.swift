import SwiftUI

struct SettingsWindow: View {
    @Environment(\.dismiss) var dismiss
    @State private var apiBaseURL = "http://127.0.0.1:8000"
    @State private var autoRefreshInterval = 2.0
    @State private var maxHistoryItems = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)

            Divider()

            // API Settings
            GroupBox("API Configuration") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Backend URL:")
                            .frame(width: 150, alignment: .leading)
                        TextField("http://127.0.0.1:8000", text: $apiBaseURL)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Auto-refresh (seconds):")
                            .frame(width: 150, alignment: .leading)
                        TextField("2.0", value: $autoRefreshInterval, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                .padding()
            }

            // History Settings
            GroupBox("History Configuration") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Max history items:")
                            .frame(width: 150, alignment: .leading)
                        TextField("100", value: $maxHistoryItems, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }
                }
                .padding()
            }

            Spacer()

            // Action buttons
            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    saveSettings()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }

    private func saveSettings() {
        // Save settings to UserDefaults
        UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        UserDefaults.standard.set(autoRefreshInterval, forKey: "autoRefreshInterval")
        UserDefaults.standard.set(maxHistoryItems, forKey: "maxHistoryItems")
    }
}

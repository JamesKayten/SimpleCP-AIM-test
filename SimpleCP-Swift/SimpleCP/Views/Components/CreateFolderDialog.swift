import SwiftUI

struct CreateFolderDialog: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var snippetService: SnippetService

    @State private var folderName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create New Folder")
                .font(.title2)
                .fontWeight(.bold)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Folder Name")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("Enter folder name", text: $folderName)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Create") {
                    createFolder()
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(folderName.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }

    private func createFolder() {
        Task {
            await snippetService.createFolder(name: folderName)
            dismiss()
        }
    }
}

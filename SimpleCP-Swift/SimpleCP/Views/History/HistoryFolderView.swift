import SwiftUI

struct HistoryFolderView: View {
    let folder: HistoryFolder
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Folder header
            HStack {
                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .foregroundColor(.blue)

                Text(folder.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text("\(folder.itemCount) items")
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
                    isExpanded.toggle()
                }
            }

            // Folder details (when expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Range:")
                        Text("\(folder.startIndex) - \(folder.endIndex)")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                    .padding(.leading, 28)
                }
            }
        }
    }
}

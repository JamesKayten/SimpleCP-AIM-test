import Foundation

// MARK: - Clipboard Item Model
struct ClipboardItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let clipId: String
    let content: String
    let contentType: String
    let timestamp: Date
    let displayString: String
    let sourceApp: String?
    let itemType: String
    let hasName: Bool
    let snippetName: String?
    let folderPath: String?
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case clipId = "clip_id"
        case content
        case contentType = "content_type"
        case timestamp
        case displayString = "display_string"
        case sourceApp = "source_app"
        case itemType = "item_type"
        case hasName = "has_name"
        case snippetName = "snippet_name"
        case folderPath = "folder_path"
        case tags
    }

    var isSnippet: Bool {
        itemType == "snippet"
    }

    var isHistory: Bool {
        itemType == "history"
    }

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var previewText: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
}

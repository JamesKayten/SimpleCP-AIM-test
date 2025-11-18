import Foundation

// MARK: - Request Models

struct CreateSnippetRequest: Codable {
    let content: String?
    let fromClipId: String?
    let name: String
    let folder: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case content
        case fromClipId = "from_clip_id"
        case name
        case folder
        case tags
    }
}

struct UpdateSnippetRequest: Codable {
    let name: String?
    let tags: [String]?
}

// MARK: - Response Models

struct HistoryFolder: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let startIndex: Int
    let endIndex: Int
    let itemCount: Int

    enum CodingKeys: String, CodingKey {
        case name
        case startIndex = "start_index"
        case endIndex = "end_index"
        case itemCount = "item_count"
    }
}

struct SearchResults: Codable {
    let historyResults: [ClipboardItem]
    let snippetResults: [ClipboardItem]
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case historyResults = "history_results"
        case snippetResults = "snippet_results"
        case totalResults = "total_results"
    }
}

struct Stats: Codable {
    let historyCount: Int
    let snippetCount: Int
    let folderCount: Int
    let totalItems: Int

    enum CodingKeys: String, CodingKey {
        case historyCount = "history_count"
        case snippetCount = "snippet_count"
        case folderCount = "folder_count"
        case totalItems = "total_items"
    }
}

struct HealthStatus: Codable {
    let status: String
    let timestamp: Date?
}

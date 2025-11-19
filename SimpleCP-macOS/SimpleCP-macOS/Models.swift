import Foundation

// MARK: - Clipboard Item Model
struct ClipboardItem: Codable, Identifiable {
    let id: String
    let content: String
    let timestamp: String
    let name: String?
    let tags: [String]?
    let folder: String?

    enum CodingKeys: String, CodingKey {
        case id = "clip_id"
        case content
        case timestamp
        case name
        case tags
        case folder
    }
}

// MARK: - Snippet Folder Response
struct SnippetFolder: Codable {
    let folderName: String
    let snippets: [ClipboardItem]

    enum CodingKeys: String, CodingKey {
        case folderName = "folder_name"
        case snippets
    }
}

// MARK: - Search Response
struct SearchResponse: Codable {
    let history: [ClipboardItem]
    let snippets: [ClipboardItem]
}

// MARK: - Stats Response
struct StatsResponse: Codable {
    let historyCount: Int
    let snippetCount: Int
    let folderCount: Int
    let totalSize: Int

    enum CodingKeys: String, CodingKey {
        case historyCount = "history_count"
        case snippetCount = "snippet_count"
        case folderCount = "folder_count"
        case totalSize = "total_size"
    }
}

// MARK: - Create Snippet Request
struct CreateSnippetRequest: Codable {
    let clipId: String?
    let content: String?
    let name: String?
    let folder: String?
    let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case clipId = "clip_id"
        case content
        case name
        case folder
        case tags
    }
}

// MARK: - Success Response
struct SuccessResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Status Response
struct StatusResponse: Codable {
    let monitoring: Bool
    let historyCount: Int
    let snippetCount: Int

    enum CodingKeys: String, CodingKey {
        case monitoring
        case historyCount = "history_count"
        case snippetCount = "snippet_count"
    }
}

// MARK: - Export Data
struct ExportData: Codable {
    let version: String
    let exportDate: String
    let snippets: [ClipboardItem]

    enum CodingKeys: String, CodingKey {
        case version
        case exportDate = "export_date"
        case snippets
    }
}

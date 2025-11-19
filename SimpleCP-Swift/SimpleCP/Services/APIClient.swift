import Foundation

// MARK: - API Client
class APIClient: ObservableObject {
    private let baseURL = "http://127.0.0.1:8000"

    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case serverError(Int)
    }

    // MARK: - History Endpoints
    func getHistory() async throws -> [ClipboardItem] {
        try await request(endpoint: "/api/history", method: "GET")
    }

    func getHistoryRecent() async throws -> [ClipboardItem] {
        try await request(endpoint: "/api/history/recent", method: "GET")
    }

    func getHistoryFolders() async throws -> [HistoryFolder] {
        try await request(endpoint: "/api/history/folders", method: "GET")
    }

    func deleteHistoryItem(id: String) async throws {
        try await request(endpoint: "/api/history/\(id)", method: "DELETE")
    }

    func clearHistory() async throws {
        try await request(endpoint: "/api/history", method: "DELETE")
    }

    // MARK: - Snippet Endpoints
    func getSnippets() async throws -> [String: [ClipboardItem]] {
        try await request(endpoint: "/api/snippets", method: "GET")
    }

    func getSnippetFolders() async throws -> [String] {
        try await request(endpoint: "/api/snippets/folders", method: "GET")
    }

    func getSnippetFolder(name: String) async throws -> [ClipboardItem] {
        try await request(endpoint: "/api/snippets/\(name)", method: "GET")
    }

    func createSnippet(request: CreateSnippetRequest) async throws -> ClipboardItem {
        try await self.request(endpoint: "/api/snippets", method: "POST", body: request)
    }

    func updateSnippet(folder: String, itemId: String, request: UpdateSnippetRequest) async throws -> ClipboardItem {
        try await self.request(endpoint: "/api/snippets/\(folder)/\(itemId)", method: "PUT", body: request)
    }

    func deleteSnippet(folder: String, itemId: String) async throws {
        try await request(endpoint: "/api/snippets/\(folder)/\(itemId)", method: "DELETE")
    }

    func moveSnippet(folder: String, itemId: String, newFolder: String) async throws {
        struct MoveRequest: Codable {
            let newFolder: String
        }
        try await request(endpoint: "/api/snippets/\(folder)/\(itemId)/move", method: "POST", body: MoveRequest(newFolder: newFolder))
    }

    // MARK: - Folder Endpoints
    func createFolder(name: String) async throws {
        struct FolderRequest: Codable {
            let name: String
        }
        try await request(endpoint: "/api/folders", method: "POST", body: FolderRequest(name: name))
    }

    func renameFolder(oldName: String, newName: String) async throws {
        struct RenameRequest: Codable {
            let newName: String
        }
        try await request(endpoint: "/api/folders/\(oldName)", method: "PUT", body: RenameRequest(newName: newName))
    }

    func deleteFolder(name: String) async throws {
        try await request(endpoint: "/api/folders/\(name)", method: "DELETE")
    }

    // MARK: - Operations
    func copyToClipboard(itemId: String) async throws {
        struct CopyRequest: Codable {
            let clipId: String
        }
        try await request(endpoint: "/api/clipboard/copy", method: "POST", body: CopyRequest(clipId: itemId))
    }

    func search(query: String) async throws -> SearchResults {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await request(endpoint: "/api/search?q=\(encoded)", method: "GET")
    }

    func getStats() async throws -> Stats {
        try await request(endpoint: "/api/stats", method: "GET")
    }

    func getHealth() async throws -> HealthStatus {
        try await request(endpoint: "/health", method: "GET")
    }

    // MARK: - Generic Request Handler
    private func request<T: Decodable>(endpoint: String, method: String) async throws -> T {
        try await request(endpoint: endpoint, method: method, body: Optional<String>.none)
    }

    private func request<T: Decodable, B: Encodable>(endpoint: String, method: String, body: B?) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func request(endpoint: String, method: String) async throws {
        try await request(endpoint: endpoint, method: method, body: Optional<String>.none)
    }

    private func request<B: Encodable>(endpoint: String, method: String, body: B?) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "Invalid response", code: 0))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

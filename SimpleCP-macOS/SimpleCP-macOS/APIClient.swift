import Foundation

class APIClient: ObservableObject {
    private let baseURL: String

    @Published var isConnected: Bool = false
    @Published var errorMessage: String?

    init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
    }

    // MARK: - Connection Test
    func testConnection() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            errorMessage = "Invalid URL"
            return false
        }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                let connected = httpResponse.statusCode == 200
                DispatchQueue.main.async {
                    self.isConnected = connected
                    self.errorMessage = connected ? nil : "Server returned \(httpResponse.statusCode)"
                }
                return connected
            }
        } catch {
            DispatchQueue.main.async {
                self.isConnected = false
                self.errorMessage = error.localizedDescription
            }
        }
        return false
    }

    // MARK: - History Endpoints
    func fetchHistory(limit: Int? = nil) async throws -> [ClipboardItem] {
        var urlString = "\(baseURL)/api/history"
        if let limit = limit {
            urlString += "?limit=\(limit)"
        }
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ClipboardItem].self, from: data)
    }

    func deleteHistoryItem(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/history/\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Snippet Endpoints
    func fetchSnippets() async throws -> [SnippetFolder] {
        guard let url = URL(string: "\(baseURL)/api/snippets") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([SnippetFolder].self, from: data)
    }

    func createSnippet(request: CreateSnippetRequest) async throws -> ClipboardItem {
        guard let url = URL(string: "\(baseURL)/api/snippets") else {
            throw URLError(.badURL)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ClipboardItem.self, from: data)
    }

    // MARK: - Search Endpoint
    func search(query: String) async throws -> SearchResponse {
        guard var components = URLComponents(string: "\(baseURL)/api/search") else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "q", query)]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(SearchResponse.self, from: data)
    }

    // MARK: - Stats Endpoint
    func fetchStats() async throws -> StatsResponse {
        guard let url = URL(string: "\(baseURL)/api/stats") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(StatsResponse.self, from: data)
    }

    // MARK: - Status Endpoint
    func fetchStatus() async throws -> StatusResponse {
        guard let url = URL(string: "\(baseURL)/api/status") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(StatusResponse.self, from: data)
    }

    // MARK: - Export/Import
    func exportSnippets() async throws -> ExportData {
        guard let url = URL(string: "\(baseURL)/api/export") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ExportData.self, from: data)
    }

    func importSnippets(data: ExportData) async throws {
        guard let url = URL(string: "\(baseURL)/api/import") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(data)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}

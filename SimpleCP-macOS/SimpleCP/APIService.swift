import Foundation

class APIService {
    private let baseURL = "http://localhost:8000"
    private let session = URLSession.shared

    // MARK: - API Endpoints

    func saveClipboardItem(_ item: ClipboardItem) async {
        let url = URL(string: "\(baseURL)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "content": item.content,
            "timestamp": ISO8601DateFormatter().string(from: item.timestamp),
            "category": item.category?.rawValue ?? "text"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Save item response: \(httpResponse.statusCode)")
            }
        } catch {
            print("Error saving item: \(error)")
        }
    }

    func loadClipboardItems() async -> [ClipboardItem] {
        let url = URL(string: "\(baseURL)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let apiItems = try decoder.decode([APIClipboardItem].self, from: data)
                return apiItems.map { apiItem in
                    ClipboardItem(
                        content: apiItem.content,
                        timestamp: apiItem.timestamp,
                        category: ClipboardItem.ItemCategory(rawValue: apiItem.category ?? "text")
                    )
                }
            }
        } catch {
            print("Error loading items: \(error)")
        }

        return []
    }

    func deleteClipboardItem(_ id: UUID) async {
        let url = URL(string: "\(baseURL)/items/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Delete item response: \(httpResponse.statusCode)")
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }

    func searchClipboardItems(_ query: String) async -> [ClipboardItem] {
        guard !query.isEmpty else { return await loadClipboardItems() }

        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "\(baseURL)/items/search?q=\(encodedQuery)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let apiItems = try decoder.decode([APIClipboardItem].self, from: data)
                return apiItems.map { apiItem in
                    ClipboardItem(
                        content: apiItem.content,
                        timestamp: apiItem.timestamp,
                        category: ClipboardItem.ItemCategory(rawValue: apiItem.category ?? "text")
                    )
                }
            }
        } catch {
            print("Error searching items: \(error)")
        }

        return []
    }

    func clearAllItems() async {
        let url = URL(string: "\(baseURL)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Clear all response: \(httpResponse.statusCode)")
            }
        } catch {
            print("Error clearing all items: \(error)")
        }
    }

    func getServerStatus() async -> Bool {
        let url = URL(string: "\(baseURL)/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (_, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Error checking server status: \(error)")
        }

        return false
    }
}

// MARK: - API Models

private struct APIClipboardItem: Codable {
    let id: String
    let content: String
    let timestamp: Date
    let category: String?
}
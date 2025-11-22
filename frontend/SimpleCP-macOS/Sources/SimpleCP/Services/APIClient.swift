//
//  APIClient.swift
//  SimpleCP
//
//  API client for backend communication
//

import Foundation
import os.log

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let logger = Logger(subsystem: "com.simplecp.app", category: "api")

    init(baseURL: String = "http://localhost:8080") {
        self.baseURL = baseURL
    }

    // MARK: - Folder Operations

    func renameFolder(oldName: String, newName: String) async throws {
        let urlString = "\(baseURL)/api/folders/\(oldName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? oldName)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["new_name": newName]
        request.httpBody = try JSONEncoder().encode(body)

        logger.info("📡 API: Renaming folder '\(oldName)' to '\(newName)'")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                logger.error("❌ API Error: \(httpResponse.statusCode) - \(errorMessage)")
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            logger.info("✅ Folder renamed successfully")
        } catch let error as APIError {
            throw error
        } catch {
            logger.error("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    func createFolder(name: String) async throws {
        let urlString = "\(baseURL)/api/folders"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["folder_name": name]
        request.httpBody = try JSONEncoder().encode(body)

        logger.info("📡 API: Creating folder '\(name)'")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                logger.error("❌ API Error: \(httpResponse.statusCode) - \(errorMessage)")
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            logger.info("✅ Folder created successfully")
        } catch let error as APIError {
            throw error
        } catch {
            logger.error("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    func deleteFolder(name: String) async throws {
        let urlString = "\(baseURL)/api/folders/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name)"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        logger.info("📡 API: Deleting folder '\(name)'")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                logger.error("❌ API Error: \(httpResponse.statusCode) - \(errorMessage)")
                throw APIError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
            }

            logger.info("✅ Folder deleted successfully")
        } catch let error as APIError {
            throw error
        } catch {
            logger.error("❌ Network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }
}

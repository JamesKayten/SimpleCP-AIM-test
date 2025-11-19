import Foundation

enum AppConstants {
    static let defaultAPIBaseURL = "http://127.0.0.1:8000"
    static let defaultRefreshInterval: TimeInterval = 2.0
    static let defaultMaxHistoryItems = 100

    enum UserDefaultsKeys {
        static let apiBaseURL = "apiBaseURL"
        static let autoRefreshInterval = "autoRefreshInterval"
        static let maxHistoryItems = "maxHistoryItems"
    }

    enum ContentTypes {
        static let text = "text"
        static let url = "url"
        static let email = "email"
        static let code = "code"
    }

    enum ItemTypes {
        static let history = "history"
        static let snippet = "snippet"
    }
}

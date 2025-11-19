import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let category: ItemCategory?

    enum ItemCategory: String, Codable, CaseIterable {
        case url = "URL"
        case email = "Email"
        case phone = "Phone"
        case code = "Code"
        case text = "Text"
    }
}

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var items: [ClipboardItem] = []
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let apiService = APIService()

    init() {
        startMonitoring()
        loadItems()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        guard let content = pasteboard.string(forType: .string),
              !content.isEmpty,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        // Check if this content already exists (avoid duplicates)
        if !items.contains(where: { $0.content == content }) {
            addItem(content: content)
        }
    }

    func addItem(content: String) {
        let category = categorizeContent(content)
        let item = ClipboardItem(
            content: content,
            timestamp: Date(),
            category: category
        )

        DispatchQueue.main.async {
            self.items.insert(item, at: 0)

            // Keep only the latest 100 items
            if self.items.count > 100 {
                self.items = Array(self.items.prefix(100))
            }

            self.saveItems()
        }

        // Send to API in background
        Task {
            await apiService.saveClipboardItem(item)
        }
    }

    private func categorizeContent(_ content: String) -> ClipboardItem.ItemCategory? {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)

        // URL detection
        if let url = URL(string: trimmedContent),
           url.scheme != nil {
            return .url
        }

        // Email detection
        let emailRegex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        if trimmedContent.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) != nil {
            return .email
        }

        // Phone detection
        let phoneRegex = #"^\+?[\d\s\-\(\)]{10,}$"#
        if trimmedContent.range(of: phoneRegex, options: .regularExpression) != nil {
            return .phone
        }

        // Code detection (contains programming keywords or symbols)
        let codeKeywords = ["function", "class", "import", "export", "const", "let", "var", "if", "else", "for", "while", "{", "}", "()", "[]", "//", "/*", "*/"]
        let lowercaseContent = trimmedContent.lowercased()
        if codeKeywords.contains(where: { lowercaseContent.contains($0) }) {
            return .code
        }

        return .text
    }

    func copyToClipboard(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }

    func deleteItem(_ id: UUID) {
        DispatchQueue.main.async {
            self.items.removeAll { $0.id == id }
            self.saveItems()
        }

        // Delete from API in background
        Task {
            await apiService.deleteClipboardItem(id)
        }
    }

    func clearAll() {
        DispatchQueue.main.async {
            self.items.removeAll()
            self.saveItems()
        }

        Task {
            await apiService.clearAllItems()
        }
    }

    // MARK: - Persistence

    private func saveItems() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: "clipboard_items")
        }
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: "clipboard_items") else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let loadedItems = try? decoder.decode([ClipboardItem].self, from: data) {
            DispatchQueue.main.async {
                self.items = loadedItems
            }
        }
    }

    // MARK: - Search

    func searchItems(_ query: String) -> [ClipboardItem] {
        if query.isEmpty {
            return Array(items.prefix(20))
        }

        return items.filter { item in
            item.content.localizedCaseInsensitiveContains(query)
        }
    }

    deinit {
        timer?.invalidate()
    }
}
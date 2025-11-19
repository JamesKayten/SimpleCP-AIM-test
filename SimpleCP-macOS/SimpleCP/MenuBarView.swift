import SwiftUI
import AppKit

class StatusBarController: ObservableObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var clipboardManager = ClipboardManager.shared

    init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        popover = NSPopover()

        setupStatusBarButton()
        setupPopover()
    }

    private func setupStatusBarButton() {
        guard let statusBarButton = statusItem.button else { return }

        // Set the icon for the menu bar
        let icon = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "SimpleCP")
        icon?.size = NSSize(width: 18, height: 18)
        statusBarButton.image = icon

        statusBarButton.action = #selector(togglePopover)
        statusBarButton.target = self
    }

    private func setupPopover() {
        popover.contentViewController = NSHostingController(rootView: MenuBarContentView())
        popover.behavior = .transient
    }

    @objc func togglePopover() {
        if popover.isShown {
            hidePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let statusBarButton = statusItem.button else { return }
        popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.minY)
    }

    private func hidePopover() {
        popover.performClose(nil)
    }
}

struct MenuBarContentView: View {
    @StateObject private var clipboardManager = ClipboardManager.shared
    @State private var searchText = ""

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return clipboardManager.items.prefix(10).map { $0 }
        } else {
            return clipboardManager.items.filter { item in
                item.content.localizedCaseInsensitiveContains(searchText)
            }.prefix(10).map { $0 }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.blue)
                Text("SimpleCP")
                    .font(.headline)
                Spacer()
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search clipboard...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Clipboard items list
            if filteredItems.isEmpty {
                VStack {
                    Image(systemName: "clipboard")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No clipboard items yet" : "No items match your search")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(filteredItems.enumerated()), id: \.offset) { index, item in
                            ClipboardItemRow(
                                item: item,
                                index: index + 1,
                                onSelect: {
                                    clipboardManager.copyToClipboard(item.content)
                                    // Close popover after selection
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        NSApp.keyWindow?.close()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()

            // Footer with actions
            HStack {
                Button("Clear All") {
                    clipboardManager.clearAll()
                }
                .foregroundColor(.red)

                Spacer()

                Text("\(clipboardManager.items.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 350, height: 400)
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let index: Int
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack {
            // Index number
            Text("\(index)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                // Content preview
                Text(item.content)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Metadata
                HStack {
                    Text(item.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let category = item.category {
                        Text(category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            // Actions
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onSelect) {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Copy to clipboard")

                    Button(action: {
                        ClipboardManager.shared.deleteItem(item.id)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete item")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color(NSColor.selectedControlColor).opacity(0.3) : Color.clear)
        .cornerRadius(6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
    }
}
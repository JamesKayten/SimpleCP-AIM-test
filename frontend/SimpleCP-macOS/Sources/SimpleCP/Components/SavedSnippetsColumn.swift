//
//  SavedSnippetsColumn.swift
//  SimpleCP
//
//  Created by SimpleCP
//

import SwiftUI

struct SavedSnippetsColumn: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    let searchText: String
    @Binding var selectedFolderId: UUID?

    @State private var hoveredSnippetId: UUID?
    @State private var editingSnippetId: UUID?

    private var filteredSnippets: [Snippet] {
        if searchText.isEmpty {
            return clipboardManager.snippets
        }
        let (_, snippets) = clipboardManager.search(query: searchText)
        return snippets
    }

    private var sortedFolders: [SnippetFolder] {
        clipboardManager.folders.sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Header
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.secondary)
                Text("SAVED SNIPPETS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Folders List - Optimized for mouse wheel scrolling
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(sortedFolders) { folder in
                        FolderView(
                            folder: folder,
                            snippets: getSnippets(for: folder.id),
                            searchText: searchText,
                            isSelected: selectedFolderId == folder.id,
                            hoveredSnippetId: $hoveredSnippetId,
                            editingSnippetId: $editingSnippetId,
                            onSelect: {
                                selectedFolderId = folder.id
                            }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func getSnippets(for folderId: UUID) -> [Snippet] {
        let folderSnippets = clipboardManager.getSnippets(for: folderId)
        if searchText.isEmpty {
            return folderSnippets
        }
        return folderSnippets.filter { snippet in
            filteredSnippets.contains(where: { $0.id == snippet.id })
        }
    }
}

// MARK: - Snippet Item Row

struct SnippetItemRow: View {
    let snippet: Snippet
    let isHovered: Bool
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showPopover = false
    @State private var hoverTimer: Timer?
    @State private var localHover = false

    var body: some View {
        HStack(spacing: 8) {
            // Favorite indicator
            if snippet.isFavorite {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
            }

            // Snippet name
            VStack(alignment: .leading, spacing: 2) {
                Text(snippet.name)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                if !snippet.tags.isEmpty {
                    Text(snippet.tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Actions (shown on hover)
            if isHovered || localHover {
                HStack(spacing: 4) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Edit")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Delete")
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill((isHovered || localHover) ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder((isHovered || localHover) ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
        .popover(isPresented: $showPopover, arrowEdge: .trailing) {
            SnippetContentPopover(snippet: snippet)
        }
        .onContinuousHover { phase in
            switch phase {
            case .active(_):
                localHover = true
                // Show popover after a delay
                hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                    showPopover = true
                }
            case .ended:
                localHover = false
                // Cancel timer and hide popover
                hoverTimer?.invalidate()
                hoverTimer = nil
                showPopover = false
            }
        }
    }
}

// MARK: - Snippet Content Popover

struct SnippetContentPopover: View {
    let snippet: Snippet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                if snippet.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 11))
                }
                Text(snippet.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text(snippet.modifiedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            // Tags
            if !snippet.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(snippet.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.7))
                            .cornerRadius(4)
                    }
                }
            }
            
            Divider()
            
            // Full content
            ScrollView {
                Text(snippet.content)
                    .font(.system(size: 11, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 400, maxHeight: 300)
            
            // Footer with character count
            HStack {
                Text("\(snippet.content.count) characters")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                if snippet.content.components(separatedBy: .newlines).count > 1 {
                    Text("\(snippet.content.components(separatedBy: .newlines).count) lines")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(minWidth: 300)
    }
}

// MARK: - Preview

#Preview {
    SavedSnippetsColumn(searchText: "", selectedFolderId: .constant(nil))
        .environmentObject(ClipboardManager())
        .frame(width: 300, height: 400)
}

//
//  RecentClipsColumn.swift
//  SimpleCP
//
//  Created by SimpleCP
//

import SwiftUI

struct RecentClipsColumn: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    let searchText: String
    let onSaveAsSnippet: (ClipItem) -> Void

    @State private var hoveredClipId: UUID?
    @State private var selectedClipId: UUID?
    @State private var expandedGroups: Set<String> = []

    private var filteredClips: [ClipItem] {
        if searchText.isEmpty {
            return clipboardManager.clipHistory
        }
        let (clips, _) = clipboardManager.search(query: searchText)
        return clips
    }

    private var recentClips: [ClipItem] {
        Array(filteredClips.prefix(10))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column Header
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.secondary)
                Text("RECENT CLIPS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Clips List - Optimized for mouse wheel scrolling
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 1) {
                    // Recent 10 clips
                    ForEach(Array(recentClips.enumerated()), id: \.element.id) { index, clip in
                        ClipItemRow(
                            index: index + 1,
                            clip: clip,
                            isHovered: hoveredClipId == clip.id,
                            isSelected: selectedClipId == clip.id,
                            onCopy: {
                                clipboardManager.copyToClipboard(clip.content)
                                selectedClipId = clip.id
                            },
                            onSave: {
                                onSaveAsSnippet(clip)
                            },
                            onDelete: {
                                clipboardManager.removeFromHistory(item: clip)
                            }
                        )
                        .onHover { isHovered in
                            hoveredClipId = isHovered ? clip.id : nil
                        }
                        .contextMenu {
                            Button("Copy") {
                                clipboardManager.copyToClipboard(clip.content)
                            }
                            Button("Save as Snippet...") {
                                onSaveAsSnippet(clip)
                            }
                            Divider()
                            Button("Remove from History") {
                                clipboardManager.removeFromHistory(item: clip)
                            }
                        }
                    }

                    // Grouped history folders
                    if filteredClips.count > 10 {
                        Divider()
                            .padding(.vertical, 8)

                        ForEach(historyGroups, id: \.range) { group in
                            HistoryGroupDisclosure(
                                range: group.range,
                                clips: group.clips,
                                isExpanded: expandedGroups.contains(group.range),
                                onToggle: {
                                    if expandedGroups.contains(group.range) {
                                        expandedGroups.remove(group.range)
                                    } else {
                                        expandedGroups.insert(group.range)
                                    }
                                },
                                hoveredClipId: $hoveredClipId,
                                selectedClipId: $selectedClipId,
                                onSaveAsSnippet: onSaveAsSnippet,
                                clipboardManager: clipboardManager
                            )
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - History Groups

    private var historyGroups: [(range: String, clips: [ClipItem])] {
        var groups: [(String, [ClipItem])] = []
        let total = filteredClips.count

        for i in stride(from: 11, to: total + 1, by: 10) {
            let start = i
            let end = min(i + 9, total)
            let clipsInRange = Array(filteredClips[safe: start - 1..<end] ?? [])
            if !clipsInRange.isEmpty {
                groups.append(("\(start) - \(end)", clipsInRange))
            }
        }

        return groups
    }
}

// MARK: - Clip Item Row

struct ClipItemRow: View {
    let index: Int
    let clip: ClipItem
    let isHovered: Bool
    let isSelected: Bool
    let onCopy: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    
    @State private var showPopover = false
    @State private var hoverTimer: Timer?

    var body: some View {
        HStack(spacing: 8) {
            // Index
            Text("\(index).")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .trailing)

            // Content preview
            VStack(alignment: .leading, spacing: 2) {
                Text(clip.preview)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(clip.displayTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Actions (shown on hover)
            if isHovered {
                HStack(spacing: 4) {
                    Button(action: onSave) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Save as snippet")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Remove")
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor.opacity(0.1) : (isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear))
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
        .popover(isPresented: $showPopover, arrowEdge: .trailing) {
            ClipContentPopover(clip: clip)
        }
        .onHover { hovering in
            if hovering {
                // Show popover after a short delay
                hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                    showPopover = true
                }
            } else {
                // Cancel timer and hide popover
                hoverTimer?.invalidate()
                hoverTimer = nil
                showPopover = false
            }
        }
    }
}

// MARK: - Clip Content Popover

struct ClipContentPopover: View {
    let clip: ClipItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: contentTypeIcon)
                    .foregroundColor(.secondary)
                Text(contentTypeLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text(clip.displayTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Full content
            ScrollView {
                Text(clip.content)
                    .font(.system(size: 11, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: 400, maxHeight: 300)
            
            // Footer with character count
            HStack {
                Text("\(clip.content.count) characters")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                Spacer()
                if clip.content.components(separatedBy: .newlines).count > 1 {
                    Text("\(clip.content.components(separatedBy: .newlines).count) lines")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .frame(minWidth: 300)
    }
    
    private var contentTypeIcon: String {
        switch clip.contentType {
        case .text: return "doc.text"
        case .url: return "link"
        case .email: return "envelope"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .unknown: return "doc.questionmark"
        }
    }
    
    private var contentTypeLabel: String {
        switch clip.contentType {
        case .text: return "Text"
        case .url: return "URL"
        case .email: return "Email"
        case .code: return "Code"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - History Group Disclosure

struct HistoryGroupDisclosure: View {
    let range: String
    let clips: [ClipItem]
    let isExpanded: Bool
    let onToggle: () -> Void
    @Binding var hoveredClipId: UUID?
    @Binding var selectedClipId: UUID?
    let onSaveAsSnippet: (ClipItem) -> Void
    let clipboardManager: ClipboardManager
    
    @State private var isHovered: Bool = false
    @State private var showFlyout: Bool = false
    @State private var hoverTimer: Timer?
    @State private var flyoutHovered: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 12)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text(range)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("(\(clips.count) clips)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                print("🔶 GROUP HOVER: \(hovering) on range: \(range)")
                isHovered = hovering
                if hovering {
                    hoverTimer?.invalidate()
                    hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        print("🟦 SHOWING GROUP FLYOUT for range: \(range)")
                        showFlyout = true
                    }
                } else {
                    hoverTimer?.invalidate()
                    hoverTimer = nil
                    // Keep flyout open if mouse is over flyout
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if !isHovered && !flyoutHovered {
                            showFlyout = false
                        }
                    }
                }
            }
            .popover(isPresented: $showFlyout, arrowEdge: .trailing) {
                ClipGroupFlyout(
                    range: range,
                    clips: clips,
                    clipboardManager: clipboardManager,
                    onSaveAsSnippet: onSaveAsSnippet,
                    onHoverChange: { hovering in
                        flyoutHovered = hovering
                    },
                    onClose: { 
                        showFlyout = false
                        flyoutHovered = false
                    }
                )
                .onAppear {
                    print("✅ GROUP FLYOUT APPEARED for range: \(range)")
                    flyoutHovered = true
                }
                .onDisappear {
                    flyoutHovered = false
                }
            }
            
            // Expanded clips
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(Array(clips.enumerated()), id: \.element.id) { index, clip in
                        ClipItemRow(
                            index: Int(range.components(separatedBy: " - ").first ?? "0")! + index,
                            clip: clip,
                            isHovered: hoveredClipId == clip.id,
                            isSelected: selectedClipId == clip.id,
                            onCopy: {
                                clipboardManager.copyToClipboard(clip.content)
                                selectedClipId = clip.id
                            },
                            onSave: {
                                onSaveAsSnippet(clip)
                            },
                            onDelete: {
                                clipboardManager.removeFromHistory(item: clip)
                            }
                        )
                        .onHover { isHovered in
                            hoveredClipId = isHovered ? clip.id : nil
                        }
                        .contextMenu {
                            Button("Copy") {
                                clipboardManager.copyToClipboard(clip.content)
                            }
                            Button("Save as Snippet...") {
                                onSaveAsSnippet(clip)
                            }
                            Divider()
                            Button("Remove from History") {
                                clipboardManager.removeFromHistory(item: clip)
                            }
                        }
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}

// MARK: - History Group Row (Deprecated - keeping for compatibility)

struct HistoryGroupRow: View {
    let range: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: "folder")
                .foregroundColor(.secondary)
            Text(range)
                .font(.system(size: 12))
            Text("(\(count) clips)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
        if range.lowerBound >= 0 && range.upperBound <= count {
            return self[range]
        }
        return nil
    }
}

// MARK: - Clip Group Flyout

struct ClipGroupFlyout: View {
    let range: String
    let clips: [ClipItem]
    let clipboardManager: ClipboardManager
    let onSaveAsSnippet: (ClipItem) -> Void
    let onHoverChange: (Bool) -> Void
    let onClose: () -> Void
    
    @State private var hoveredClipId: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Text(range)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text("\(clips.count)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Clips List
            if clips.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No clips")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(clips) { clip in
                            FlyoutClipRow(
                                clip: clip,
                                isHovered: hoveredClipId == clip.id,
                                onPaste: {
                                    clipboardManager.copyToClipboard(clip.content)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        pasteToActiveApp()
                                        onClose()
                                    }
                                },
                                onCopy: {
                                    clipboardManager.copyToClipboard(clip.content)
                                },
                                onSave: {
                                    onSaveAsSnippet(clip)
                                },
                                onDelete: {
                                    clipboardManager.removeFromHistory(item: clip)
                                }
                            )
                            .onHover { isHovered in
                                hoveredClipId = isHovered ? clip.id : nil
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
        }
        .frame(minWidth: 300, maxWidth: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .onHover { hovering in
            onHoverChange(hovering)
        }
    }
    
    private func pasteToActiveApp() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyVDown?.flags = .maskCommand
        let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyVUp?.flags = .maskCommand
        keyVDown?.post(tap: .cghidEventTap)
        keyVUp?.post(tap: .cghidEventTap)
    }
}

// MARK: - Flyout Clip Row

struct FlyoutClipRow: View {
    let clip: ClipItem
    let isHovered: Bool
    let onPaste: () -> Void
    let onCopy: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon
            Image(systemName: contentTypeIcon)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(clip.preview)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(2)
                
                Text(clip.displayTime)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Hover action button
            if isHovered {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.12) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
        .contextMenu {
            Button("Paste Immediately") {
                onPaste()
            }
            .keyboardShortcut(.return)
            
            Divider()
            
            Button("Copy to Clipboard") {
                onCopy()
            }
            
            Button("Save as Snippet...") {
                onSave()
            }
            
            Divider()
            
            Button("Remove from History") {
                onDelete()
            }
        }
    }
    
    private var contentTypeIcon: String {
        switch clip.contentType {
        case .text: return "doc.text"
        case .url: return "link"
        case .email: return "envelope"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .unknown: return "doc.questionmark"
        }
    }
}

// MARK: - Preview

#Preview {
    RecentClipsColumn(
        searchText: "",
        onSaveAsSnippet: { _ in }
    )
    .environmentObject(ClipboardManager())
    .frame(width: 300, height: 400)
}


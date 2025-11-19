# SimpleCP - Swift Frontend

Native macOS SwiftUI frontend for SimpleCP clipboard manager.

## Overview

This is a complete Swift/SwiftUI frontend that connects to the Python backend via REST API. It provides a modern two-column interface for managing clipboard history and snippets.

## Architecture

```
SimpleCP-Swift/
├── App/
│   ├── SimpleCPApp.swift          # App entry point
│   └── ContentView.swift          # Main container view
├── Views/
│   ├── Components/
│   │   ├── HeaderView.swift       # Title + search + settings
│   │   ├── ControlBar.swift       # Action buttons
│   │   ├── SettingsWindow.swift   # Settings dialog
│   │   ├── ManageFoldersView.swift
│   │   └── CreateFolderDialog.swift
│   ├── History/
│   │   ├── HistoryColumnView.swift
│   │   ├── HistoryItemView.swift
│   │   └── HistoryFolderView.swift
│   ├── Snippets/
│   │   ├── SnippetsColumnView.swift
│   │   ├── SnippetFolderView.swift
│   │   ├── SnippetItemView.swift
│   │   └── SaveSnippetDialog.swift
│   └── Shared/
│       ├── LoadingView.swift
│       └── ErrorView.swift
├── Services/
│   ├── APIClient.swift            # HTTP client for Python backend
│   ├── ClipboardService.swift     # History operations
│   ├── SnippetService.swift       # Snippet CRUD
│   └── SearchService.swift        # Search functionality
├── Models/
│   ├── ClipboardItem.swift        # Main data model
│   ├── APIModels.swift            # API request/response models
│   └── AppState.swift             # App state management
└── Utils/
    ├── Constants.swift
    ├── DateUtils.swift
    └── StringUtils.swift
```

## Features

### Implemented
✅ Complete API integration with Python backend
✅ Two-column layout (History | Snippets)
✅ Real-time clipboard monitoring
✅ Full snippet save workflow
✅ Folder management (create, delete)
✅ Search across history and snippets
✅ Click-to-copy functionality
✅ Context menus for all items
✅ Auto-refresh history (2s interval)
✅ Loading and error states
✅ Settings window
✅ History auto-folders display

### Core Functionality

**History Column (Left)**
- Display recent clipboard items
- Auto-generated history folders (11-20, 21-30, etc.)
- Double-click to copy to clipboard
- Right-click context menu:
  - Copy to clipboard
  - Save as snippet
  - Delete item
- Clear all history

**Snippets Column (Right)**
- Organized by folders
- Expandable folder tree
- Create/delete folders
- Save snippets with:
  - Name (auto-suggested)
  - Folder (select or create new)
  - Tags (comma-separated)
- Right-click context menu:
  - Copy to clipboard
  - Delete snippet

**Search**
- Global search across history and snippets
- Real-time results
- Type indicator (text, url, email, code)

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 14.0+
- Swift 5.7+
- Python backend running on http://127.0.0.1:8000

## Setup Instructions

### 1. Start Python Backend

First, ensure the Python backend is running:

```bash
cd /path/to/SimpleCP
python daemon.py
```

Verify the backend is accessible:
```bash
curl http://127.0.0.1:8000/health
```

### 2. Open in Xcode

```bash
cd SimpleCP-Swift
open SimpleCP.xcodeproj  # Or create a new Xcode project
```

### 3. Project Configuration

In Xcode:
1. Create a new macOS App project (SwiftUI, Swift)
2. Copy all files from this directory into the project
3. Ensure all files are added to the target
4. Set deployment target to macOS 13.0
5. Add required capabilities:
   - Outgoing Connections (Client)

### 4. Build and Run

```bash
# In Xcode
Command + R
```

## API Integration

The app connects to the Python backend at `http://127.0.0.1:8000` and uses these endpoints:

**History**
- `GET /api/history/recent` - Recent items
- `GET /api/history/folders` - Auto-folders
- `DELETE /api/history/{id}` - Delete item
- `DELETE /api/history` - Clear all

**Snippets**
- `GET /api/snippets` - All snippets by folder
- `GET /api/snippets/folders` - Folder names
- `POST /api/snippets` - Create snippet
- `DELETE /api/snippets/{folder}/{id}` - Delete snippet

**Folders**
- `POST /api/folders` - Create folder
- `DELETE /api/folders/{name}` - Delete folder

**Operations**
- `POST /api/clipboard/copy` - Copy to clipboard
- `GET /api/search?q=query` - Search
- `GET /health` - Health check

## Usage

### Basic Operations

1. **View History**: Recent clipboard items appear in the left column
2. **Save Snippet**: Select a history item → click "Save as Snippet"
3. **Copy Item**: Double-click any item to copy to clipboard
4. **Search**: Type in the search bar to filter items
5. **Manage Folders**: Click "Manage" to create/delete folders

### Keyboard Shortcuts

- Double-click item: Copy to clipboard
- Right-click: Show context menu
- Cmd+R: Refresh (when focused)

## Development Status

### Completed ✅
- [x] Complete project structure
- [x] All API endpoints integrated
- [x] Two-column layout
- [x] History display with folders
- [x] Snippet management
- [x] Save snippet workflow
- [x] Search functionality
- [x] Settings window
- [x] Error handling
- [x] Loading states
- [x] Auto-refresh

### Pending Items
- [ ] Menu bar integration (macOS status bar)
- [ ] Keyboard shortcuts (global hotkeys)
- [ ] Drag & drop between columns
- [ ] Enhanced visual polish
- [ ] Window persistence (size/position)
- [ ] Performance optimization for large datasets

## Technical Details

### State Management
- Uses `@StateObject` and `@EnvironmentObject` for dependency injection
- `AppState` provides centralized state management
- Services handle business logic and API calls

### Data Flow
```
User Action → View → Service → APIClient → Python Backend
Python Backend → APIClient → Service → AppState → View Update
```

### Error Handling
- Network errors are caught and displayed to user
- Loading states shown during API calls
- Error messages can be dismissed

### Performance
- Auto-refresh every 2 seconds for history
- Lazy loading for long lists
- Efficient state updates

## Troubleshooting

**Backend connection fails**
- Ensure Python daemon is running: `python daemon.py`
- Check backend URL in settings (default: http://127.0.0.1:8000)
- Verify firewall settings allow localhost connections

**No items showing**
- Refresh using the refresh button
- Check Python backend has data: `curl http://127.0.0.1:8000/api/history/recent`
- Check console for API errors

**Build errors in Xcode**
- Ensure deployment target is macOS 13.0+
- Clean build folder (Cmd+Shift+K)
- Verify all files are added to target

## Next Steps

1. **Local Testing**: Test with real clipboard data
2. **Visual Polish**: Colors, animations, spacing
3. **Menu Bar Integration**: Add status bar icon
4. **Global Shortcuts**: Keyboard hotkeys for quick access
5. **Performance**: Optimize for large datasets

## License

MIT License - Same as Python backend

---

**Built with SwiftUI | Connects to Python FastAPI backend**

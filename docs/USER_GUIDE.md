# SimpleCP User Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Features](#features)
5. [Keyboard Shortcuts](#keyboard-shortcuts)
6. [API Usage](#api-usage)

---

## Introduction

SimpleCP is a powerful clipboard manager for macOS with:
- Unlimited clipboard history
- Organized snippets with folders
- Full-text search
- REST API access
- Keyboard shortcuts

---

## Installation

### Prerequisites
- Python 3.11+
- macOS 13.0+ (for Swift frontend)

### Backend Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Start the daemon:
```bash
python daemon.py --port 8080
```

### Swift Frontend Setup

1. Open Xcode project:
```bash
open SimpleCP-macOS/SimpleCP-macOS.xcodeproj
```

2. Build and run the macOS app

---

## Configuration

### Config File

Edit `config.json` to customize SimpleCP:

```json
{
  "server": {
    "host": "127.0.0.1",
    "port": 8080
  },
  "clipboard": {
    "max_history": 50,
    "display_count": 10,
    "check_interval": 1
  },
  "logging": {
    "level": "INFO",
    "log_dir": "logs"
  }
}
```

### Environment Variables

Override config with environment variables:
- `SIMPLECP_PORT`: Server port
- `SIMPLECP_MAX_HISTORY`: Maximum history items
- `SIMPLECP_LOG_LEVEL`: Logging level

---

## Features

### Clipboard History

SimpleCP automatically tracks everything you copy:
- Up to 50 items (configurable)
- Auto-categorization (URLs, emails, code, etc.)
- Deduplication (duplicates moved to top)
- Persistent storage

### Snippets

Save frequently used text as snippets:
- Organize in folders
- Add tags for easy search
- Edit and update anytime
- Export/import for backup

### Search

Find anything in your clipboard history or snippets:
- Full-text search
- Search by tags
- Filter by type
- Real-time results

### Auto-Categorization

Content is automatically categorized as:
- **URL**: Web addresses
- **Email**: Email addresses
- **Code**: Programming code
- **JSON**: JSON data
- **SQL**: Database queries
- **Shell**: Terminal commands
- **Text**: Plain text

---

## Keyboard Shortcuts

### macOS Shortcuts

- `⌘⌥V`: Toggle clipboard panel
- `⌘⌥1-9`: Quick paste from positions 1-9
- `⌘⌥C`: Clear history
- `⌘⌥S`: Search clipboard

---

## API Usage

### Python Example

```python
import requests

# Get history
response = requests.get("http://localhost:8080/api/history")
history = response.json()

# Create snippet
snippet = {
    "content": "Hello, World!",
    "name": "Greeting",
    "folder": "Examples",
    "tags": ["demo"]
}
response = requests.post(
    "http://localhost:8080/api/snippets",
    json=snippet
)

# Search
response = requests.get(
    "http://localhost:8080/api/search?q=hello"
)
results = response.json()
```

### Swift Example

```swift
let apiClient = APIClient()

// Fetch history
Task {
    let items = try await apiClient.fetchHistory()
    print("History: \(items.count) items")
}

// Create snippet
let request = CreateSnippetRequest(
    clipId: nil,
    content: "Sample code",
    name: "Example",
    folder: "Code",
    tags: ["swift"]
)
Task {
    let snippet = try await apiClient.createSnippet(request: request)
}
```

---

## Troubleshooting

### Daemon Won't Start

1. Check port availability:
```bash
lsof -i :8080
```

2. Check logs:
```bash
tail -f logs/simplecp.log
```

### Frontend Can't Connect

1. Verify daemon is running
2. Check config.json port matches
3. Test API manually:
```bash
curl http://localhost:8080/health
```

---

## Data Management

### Backup

Export all snippets:
```bash
curl http://localhost:8080/api/export > backup.json
```

### Restore

Import from backup:
```bash
curl -X POST http://localhost:8080/api/import \
  -H "Content-Type: application/json" \
  -d @backup.json
```

---

## Advanced Usage

### Custom Scripts

Integrate with automation tools:

```bash
#!/bin/bash
# Add current clipboard to snippets
content=$(pbpaste)
curl -X POST http://localhost:8080/api/snippets \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$content\", \"name\": \"Auto\", \"folder\": \"Scripts\"}"
```

---

## Support

For issues and feature requests:
- GitHub Issues: [github.com/yourrepo/SimpleCP/issues]
- API Documentation: See docs/API.md

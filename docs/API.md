# SimpleCP REST API Documentation

## Overview

SimpleCP provides a comprehensive REST API for clipboard management, snippet organization, and search functionality.

**Base URL:** `http://localhost:8080`

**Version:** 1.0.0

## Frontend Integration

The Swift macOS frontend integrates with this API through:
- **APIClient** (`frontend/SimpleCP-macOS/Sources/SimpleCP/Services/APIClient.swift`)
- Folder operations (create, rename, delete) are synchronized with the backend
- Local UserDefaults + Backend API hybrid architecture
- Async/await error handling with automatic revert on failures

For detailed integration documentation, see: `/docs/FOLDER_API_INTEGRATION.md`

---

## Core Endpoints

### Health & Status

#### GET /health
Check API health status.

**Response:**
```json
{
  "status": "healthy",
  "stats": {
    "history_count": 10,
    "snippet_count": 5,
    "folder_count": 3,
    "max_history": 50
  }
}
```

#### GET /api/status
Get clipboard monitoring status.

**Response:**
```json
{
  "monitoring": true,
  "history_count": 10,
  "snippet_count": 5,
  "uptime_seconds": null
}
```

---

## History Management

### GET /api/history
Get all clipboard history items.

**Query Parameters:**
- `limit` (optional): Maximum number of items to return

**Response:**
```json
[
  {
    "clip_id": "abc123",
    "content": "Hello World",
    "timestamp": "2024-01-01T12:00:00",
    "content_type": "text",
    "display_string": "Hello World",
    "source_app": null,
    "item_type": "history",
    "has_name": false,
    "snippet_name": null,
    "folder_path": null,
    "tags": []
  }
]
```

### GET /api/history/recent
Get recent history items for direct display.

**Response:** Same as `/api/history` but limited to display_count

### GET /api/history/folders
Get auto-generated history folder ranges.

**Response:**
```json
[
  {
    "name": "11-20",
    "start_index": 10,
    "end_index": 19,
    "count": 10,
    "items": [...]
  }
]
```

### DELETE /api/history/{clip_id}
Delete specific history item.

**Response:**
```json
{
  "success": true,
  "message": "Item deleted"
}
```

### DELETE /api/history
Clear all clipboard history.

**Response:**
```json
{
  "success": true,
  "message": "History cleared"
}
```

---

## Snippet Management

### GET /api/snippets
Get all snippets organized by folder.

**Response:**
```json
[
  {
    "folder_name": "Code",
    "snippets": [...]
  }
]
```

### GET /api/snippets/folders
Get list of all snippet folder names.

**Response:**
```json
["Code", "Scripts", "Notes"]
```

### GET /api/snippets/{folder_name}
Get all snippets in a specific folder.

**Response:** Array of clipboard items

### POST /api/snippets
Create a new snippet.

**Request Body:**
```json
{
  "clip_id": "abc123",  // Optional: convert from history
  "content": "snippet content",  // Optional: create directly
  "name": "My Snippet",
  "folder": "Code",
  "tags": ["python", "example"]
}
```

**Response:** Created snippet object

### PUT /api/snippets/{folder_name}/{clip_id}
Update snippet properties.

**Request Body:**
```json
{
  "content": "updated content",
  "name": "Updated Name",
  "tags": ["new", "tags"]
}
```

### DELETE /api/snippets/{folder_name}/{clip_id}
Delete a specific snippet.

### POST /api/snippets/{folder_name}/{clip_id}/move
Move snippet to different folder.

**Request Body:**
```json
{
  "to_folder": "NewFolder"
}
```

---

## Folder Management

### POST /api/folders
Create new snippet folder.

**Request Body:**
```json
{
  "folder_name": "MyFolder"
}
```

### PUT /api/folders/{folder_name}
Rename snippet folder.

**Request Body:**
```json
{
  "new_name": "RenamedFolder"
}
```

### DELETE /api/folders/{folder_name}
Delete folder and all its snippets.

---

## Search

### GET /api/search
Search across history and snippets (GET).

**Query Parameters:**
- `q`: Search query

**Response:**
```json
{
  "history": [...],
  "snippets": [...]
}
```

### POST /api/search
Search across history and snippets (POST).

**Request Body:**
```json
{
  "query": "search term",
  "include_history": true,
  "include_snippets": true
}
```

---

## Statistics & Export

### GET /api/stats
Get manager statistics.

**Response:**
```json
{
  "history_count": 10,
  "snippet_count": 5,
  "folder_count": 3,
  "max_history": 50
}
```

### GET /api/export
Export all snippets.

**Response:**
```json
{
  "version": "1.0",
  "export_date": "2024-01-01T12:00:00",
  "snippets": [...],
  "metadata": {
    "folder_count": 3
  }
}
```

### POST /api/import
Import snippets from export data.

**Request Body:**
```json
{
  "version": "1.0",
  "snippets": [...]
}
```

---

## Clipboard Operations

### POST /api/clipboard/copy
Copy item to system clipboard.

**Request Body:**
```json
{
  "clip_id": "abc123"
}
```

---

## Error Responses

All endpoints return standard error responses:

```json
{
  "detail": "Error description"
}
```

**Status Codes:**
- `200`: Success
- `400`: Bad Request
- `404`: Not Found
- `409`: Conflict
- `500`: Internal Server Error

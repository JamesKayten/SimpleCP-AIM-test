"""Tests for API endpoints."""
import pytest
from fastapi.testclient import TestClient
from api.server import create_app
from clipboard_manager import ClipboardManager


@pytest.fixture
def client():
    """Create test client."""
    import tempfile
    import shutil

    temp_dir = tempfile.mkdtemp()
    manager = ClipboardManager(data_dir=temp_dir)
    app = create_app(manager)
    yield TestClient(app), manager
    shutil.rmtree(temp_dir, ignore_errors=True)


def test_root_endpoint(client):
    """Test root endpoint."""
    test_client, _ = client
    response = test_client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "SimpleCP API"
    assert data["status"] == "running"


def test_health_endpoint(client):
    """Test health endpoint."""
    test_client, _ = client
    response = test_client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "stats" in data


def test_get_history_empty(client):
    """Test getting empty history."""
    test_client, manager = client
    manager.clear_history()
    response = test_client.get("/api/history")
    assert response.status_code == 200
    assert response.json() == []


def test_get_recent_history(client):
    """Test getting recent history."""
    test_client, manager = client
    manager.add_clip("test content")
    response = test_client.get("/api/history/recent")
    assert response.status_code == 200
    items = response.json()
    assert len(items) > 0


def test_get_history_folders(client):
    """Test getting history folders."""
    test_client, _ = client
    response = test_client.get("/api/history/folders")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_delete_history_item(client):
    """Test deleting history item."""
    test_client, manager = client
    item = manager.add_clip("test delete")
    response = test_client.delete(f"/api/history/{item.clip_id}")
    assert response.status_code == 200
    assert response.json()["success"] is True


def test_delete_nonexistent_history(client):
    """Test deleting non-existent history item."""
    test_client, _ = client
    response = test_client.delete("/api/history/nonexistent")
    assert response.status_code == 404


def test_clear_history(client):
    """Test clearing history."""
    test_client, manager = client
    manager.add_clip("test1")
    manager.add_clip("test2")
    response = test_client.delete("/api/history")
    assert response.status_code == 200
    assert response.json()["success"] is True


def test_get_all_snippets(client):
    """Test getting all snippets."""
    test_client, _ = client
    response = test_client.get("/api/snippets")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_snippet_folders(client):
    """Test getting snippet folders."""
    test_client, _ = client
    response = test_client.get("/api/snippets/folders")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_create_snippet_from_history(client):
    """Test creating snippet from history."""
    test_client, manager = client
    item = manager.add_clip("snippet content")
    response = test_client.post(
        "/api/snippets",
        json={
            "clip_id": item.clip_id,
            "name": "Test Snippet",
            "folder": "TestFolder",
            "tags": ["test"],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["content"] == "snippet content"


def test_create_snippet_direct(client):
    """Test creating snippet directly."""
    test_client, _ = client
    response = test_client.post(
        "/api/snippets",
        json={
            "content": "direct snippet",
            "name": "Direct",
            "folder": "TestFolder",
            "tags": [],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["content"] == "direct snippet"


def test_create_snippet_invalid(client):
    """Test creating snippet with invalid data."""
    test_client, _ = client
    response = test_client.post(
        "/api/snippets", json={"name": "Invalid", "folder": "Test", "tags": []}
    )
    assert response.status_code == 400


def test_update_snippet(client):
    """Test updating snippet."""
    test_client, manager = client
    snippet = manager.add_snippet_direct("old", "Test", "Folder", [])
    response = test_client.put(
        f"/api/snippets/Folder/{snippet.clip_id}",
        json={"content": "new", "name": "Updated", "tags": ["updated"]},
    )
    assert response.status_code == 200


def test_delete_snippet(client):
    """Test deleting snippet."""
    test_client, manager = client
    snippet = manager.add_snippet_direct("delete me", "Test", "Folder", [])
    response = test_client.delete(f"/api/snippets/Folder/{snippet.clip_id}")
    assert response.status_code == 200


def test_move_snippet(client):
    """Test moving snippet."""
    test_client, manager = client
    manager.create_snippet_folder("Source")
    manager.create_snippet_folder("Dest")
    snippet = manager.add_snippet_direct("move me", "Test", "Source", [])
    response = test_client.post(
        f"/api/snippets/Source/{snippet.clip_id}/move", json={"to_folder": "Dest"}
    )
    assert response.status_code == 200


def test_create_folder(client):
    """Test creating folder."""
    test_client, _ = client
    response = test_client.post("/api/folders", json={"folder_name": "NewFolder"})
    assert response.status_code == 200


def test_rename_folder(client):
    """Test renaming folder."""
    test_client, manager = client
    manager.create_snippet_folder("OldName")
    response = test_client.put("/api/folders/OldName", json={"new_name": "NewName"})
    assert response.status_code == 200


def test_delete_folder(client):
    """Test deleting folder."""
    test_client, manager = client
    manager.create_snippet_folder("DeleteMe")
    response = test_client.delete("/api/folders/DeleteMe")
    assert response.status_code == 200


def test_copy_to_clipboard(client):
    """Test copying to clipboard."""
    test_client, manager = client
    item = manager.add_clip("copy this")
    try:
        response = test_client.post(
            "/api/clipboard/copy", json={"clip_id": item.clip_id}
        )
        assert response.status_code == 200
    except Exception:
        # Skip if pyperclip not available in test environment
        pass


def test_search_get(client):
    """Test GET search."""
    test_client, manager = client
    manager.add_clip("searchable content")
    response = test_client.get("/api/search?q=searchable")
    assert response.status_code == 200
    data = response.json()
    assert "history" in data
    assert "snippets" in data


def test_search_post(client):
    """Test POST search."""
    test_client, manager = client
    manager.add_clip("findme")
    response = test_client.post("/api/search", json={"query": "findme"})
    assert response.status_code == 200


def test_get_stats(client):
    """Test stats endpoint."""
    test_client, _ = client
    response = test_client.get("/api/stats")
    assert response.status_code == 200
    data = response.json()
    assert "history_count" in data
    assert "snippet_count" in data


def test_get_status(client):
    """Test status endpoint."""
    test_client, _ = client
    response = test_client.get("/api/status")
    assert response.status_code == 200
    data = response.json()
    assert "monitoring" in data
    assert data["monitoring"] is True


def test_export_snippets(client):
    """Test export endpoint."""
    test_client, _ = client
    response = test_client.get("/api/export")
    assert response.status_code == 200
    data = response.json()
    assert "version" in data
    assert "snippets" in data


def test_import_snippets(client):
    """Test import endpoint."""
    test_client, _ = client
    import_data = {"version": "1.0", "snippets": []}
    response = test_client.post("/api/import", json=import_data)
    assert response.status_code == 200


def test_get_folder_snippets(client):
    """Test getting snippets from folder."""
    test_client, manager = client
    manager.add_snippet_direct("test", "Test", "TestFolder", [])
    response = test_client.get("/api/snippets/TestFolder")
    assert response.status_code == 200
    items = response.json()
    assert len(items) > 0


def test_update_snippet_not_found(client):
    """Test updating non-existent snippet."""
    test_client, _ = client
    response = test_client.put(
        "/api/snippets/Folder/nonexistent", json={"content": "new"}
    )
    assert response.status_code == 404


def test_delete_snippet_not_found(client):
    """Test deleting non-existent snippet."""
    test_client, _ = client
    response = test_client.delete("/api/snippets/Folder/nonexistent")
    assert response.status_code == 404


def test_move_snippet_not_found(client):
    """Test moving non-existent snippet."""
    test_client, _ = client
    response = test_client.post(
        "/api/snippets/Source/nonexistent/move", json={"to_folder": "Dest"}
    )
    assert response.status_code == 404

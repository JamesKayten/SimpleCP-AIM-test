"""Tests for clipboard manager core functionality."""
import pytest
import tempfile
import shutil
from clipboard_manager import ClipboardManager


@pytest.fixture
def manager():
    """Create test clipboard manager."""
    temp_dir = tempfile.mkdtemp()
    mgr = ClipboardManager(data_dir=temp_dir)
    yield mgr
    shutil.rmtree(temp_dir, ignore_errors=True)


def test_add_clip(manager):
    """Test adding clipboard item."""
    item = manager.add_clip("test content")
    assert item.content == "test content"
    assert len(manager.history_store) == 1


def test_save_and_load_stores(manager):
    """Test persistence."""
    manager.add_clip("test1")
    manager.add_snippet_direct("snippet1", "Test", "Folder", [])
    manager.save_stores()

    new_manager = ClipboardManager(data_dir=manager.data_dir)
    assert len(new_manager.history_store) == 1
    assert len(new_manager.snippet_store) > 0


def test_search(manager):
    """Test search functionality."""
    manager.add_clip("searchable text")
    manager.add_snippet_direct("findme", "Snippet", "Folder", [])

    results = manager.search_all("searchable")
    assert len(results["history"]) == 1

    results = manager.search_all("findme")
    assert len(results["snippets"]) == 1


def test_export_import(manager):
    """Test export and import."""
    manager.add_snippet_direct("export test", "Test", "Folder", ["tag"])
    export_data = manager.export_snippets()

    assert "snippets" in export_data
    assert len(export_data["snippets"]) > 0

    new_manager = ClipboardManager(data_dir=tempfile.mkdtemp())
    success = new_manager.import_snippets(export_data)
    assert success is True


def test_get_status(manager):
    """Test status retrieval."""
    manager.add_clip("test")
    status = manager.get_status()
    assert status["monitoring"] is True
    assert status["history_count"] >= 0


def test_save_as_snippet(manager):
    """Test converting history to snippet."""
    item = manager.add_clip("convert me")
    snippet = manager.save_as_snippet(item.clip_id, "MySnippet", "Folder", ["tag"])
    assert snippet is not None
    assert snippet.snippet_name == "MySnippet"


def test_delete_history(manager):
    """Test deleting history item."""
    item = manager.add_clip("delete this")
    success = manager.delete_history_item(item.clip_id)
    assert success is True
    success = manager.delete_history_item("nonexistent")
    assert success is False

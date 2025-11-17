"""
ClipboardItem data model for SimpleCP.

Represents individual clipboard items with metadata.
"""

from datetime import datetime
from typing import Optional, Dict, Any

class ClipboardItem:
    """
    Represents a single clipboard item with metadata.

    Attributes:
        content: The text content of the clipboard item
        timestamp: When the item was created/copied
        preview: Shortened version for display
        source_app: Application that created this clipboard entry
        item_type: Type of item (history, snippet, etc.)
    """

    def __init__(
        self,
        content: str,
        timestamp: Optional[datetime] = None,
        source_app: Optional[str] = None,
        item_type: str = "history"
    ):
        self.content = content
        self.timestamp = timestamp or datetime.now()
        self.preview = self._create_preview(content)
        self.source_app = source_app
        self.item_type = item_type

    def _create_preview(self, text: str, max_length: int = 50) -> str:
        """Create a preview string for menu display."""
        clean_text = text.replace('\n', ' ').replace('\t', ' ').strip()

        if len(clean_text) <= max_length:
            return clean_text

        return clean_text[:max_length-3] + "..."

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON serialization."""
        return {
            "content": self.content,
            "timestamp": self.timestamp.isoformat(),
            "preview": self.preview,
            "source_app": self.source_app,
            "item_type": self.item_type
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'ClipboardItem':
        """Create ClipboardItem from dictionary."""
        item = cls(
            content=data["content"],
            timestamp=datetime.fromisoformat(data["timestamp"]),
            source_app=data.get("source_app"),
            item_type=data.get("item_type", "history")
        )
        return item

    def __str__(self) -> str:
        return self.preview

    def __repr__(self) -> str:
        return f"ClipboardItem(preview='{self.preview}', type='{self.item_type}')"
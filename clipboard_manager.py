"""
ClipboardManager - Main application class.

This is the core rumps.App that manages the menu bar interface,
clipboard monitoring, and coordination between stores.
"""

import rumps
import pyperclip
import json
import os
from datetime import datetime
from typing import Optional, List, Dict, Any

# Import our custom modules (to be implemented)
# from stores.history_store import HistoryStore
# from stores.snippet_store import SnippetStore
# from ui.menu_builder import MenuBuilder
# from settings import Settings

class ClipboardManager(rumps.App):
    """
    Main application class managing the menu bar clipboard manager.

    Features:
    - Automatic clipboard monitoring
    - History management
    - Snippet folders
    - Menu bar interface
    """

    def __init__(self):
        super(ClipboardManager, self).__init__(
            "📋",
            title="SimpleCP",
            quit_button=None  # We'll add our own quit option
        )

        # Core state
        self.current_clipboard = ""
        self.clipboard_history = []
        self.snippet_folders = {}

        # Configuration
        self.max_history_items = 50
        self.clipboard_check_interval = 1  # seconds

        # Initialize data directory
        self.data_dir = os.path.join(os.path.dirname(__file__), "data")
        os.makedirs(self.data_dir, exist_ok=True)

        # Setup initial menu
        self.setup_menu()

        # Load existing data
        self.load_data()

    def setup_menu(self):
        """Setup the initial menu structure."""
        # Separator and basic options
        self.menu = [
            rumps.separator,
            rumps.MenuItem("📋 Recent Clips", callback=None),
            rumps.separator,
            rumps.MenuItem("📁 Snippet Folders", callback=None),
            rumps.separator,
            rumps.MenuItem("⚙️ Preferences", callback=self.show_preferences),
            rumps.MenuItem("🗑️ Clear History", callback=self.clear_history),
            rumps.separator,
            rumps.MenuItem("❌ Quit SimpleCP", callback=self.quit_app),
        ]

    @rumps.timer(1)  # Check clipboard every second
    def check_clipboard(self, _):
        """Monitor clipboard for changes and update history."""
        try:
            current = pyperclip.paste()

            # Check if clipboard content has changed
            if current != self.current_clipboard and current.strip():
                self.current_clipboard = current
                self.add_to_history(current)
                self.update_menu()

        except Exception as e:
            print(f"Error checking clipboard: {e}")

    def add_to_history(self, text: str):
        """Add new text to clipboard history."""
        # Create history item with metadata
        item = {
            "content": text,
            "timestamp": datetime.now().isoformat(),
            "preview": self.create_preview(text)
        }

        # Remove duplicates and add to front
        self.clipboard_history = [
            item for item in self.clipboard_history
            if item["content"] != text
        ]
        self.clipboard_history.insert(0, item)

        # Limit history size
        if len(self.clipboard_history) > self.max_history_items:
            self.clipboard_history = self.clipboard_history[:self.max_history_items]

        # Auto-save
        self.save_data()

    def create_preview(self, text: str, max_length: int = 50) -> str:
        """Create a preview string for menu display."""
        # Clean up text for menu display
        clean_text = text.replace('\n', ' ').replace('\t', ' ').strip()

        if len(clean_text) <= max_length:
            return clean_text

        return clean_text[:max_length-3] + "..."

    def update_menu(self):
        """Update the menu with current clipboard history and snippets."""
        # Clear existing dynamic menu items
        self.menu.clear()

        # Add recent clips section
        if self.clipboard_history:
            self.menu.add(rumps.MenuItem("📋 Recent Clips", callback=None))
            self.menu.add(rumps.separator)

            for i, item in enumerate(self.clipboard_history[:10]):  # Show last 10
                menu_item = rumps.MenuItem(
                    f"{i+1}. {item['preview']}",
                    callback=lambda sender, content=item['content']: self.paste_item(content)
                )
                self.menu.add(menu_item)

            self.menu.add(rumps.separator)

        # Add snippet folders section (placeholder)
        self.menu.add(rumps.MenuItem("📁 Snippet Folders", callback=None))
        self.menu.add(rumps.MenuItem("   (Coming soon...)", callback=None))
        self.menu.add(rumps.separator)

        # Add persistent menu items
        self.menu.add(rumps.MenuItem("⚙️ Preferences", callback=self.show_preferences))
        self.menu.add(rumps.MenuItem("🗑️ Clear History", callback=self.clear_history))
        self.menu.add(rumps.separator)
        self.menu.add(rumps.MenuItem("❌ Quit SimpleCP", callback=self.quit_app))

    def paste_item(self, content: str):
        """Copy selected item to clipboard."""
        try:
            pyperclip.copy(content)
            # TODO: Show brief notification
            print(f"📋 Copied to clipboard: {self.create_preview(content)}")
        except Exception as e:
            print(f"Error copying to clipboard: {e}")

    def clear_history(self, _):
        """Clear all clipboard history."""
        self.clipboard_history = []
        self.save_data()
        self.update_menu()
        print("🗑️ Clipboard history cleared")

    def show_preferences(self, _):
        """Show preferences window (placeholder)."""
        # TODO: Implement preferences window
        rumps.alert("Preferences", "Coming soon!")

    def quit_app(self, _):
        """Quit the application."""
        print("👋 Goodbye from SimpleCP!")
        rumps.quit_application()

    def load_data(self):
        """Load clipboard history and snippets from storage."""
        history_file = os.path.join(self.data_dir, "history.json")
        snippets_file = os.path.join(self.data_dir, "snippets.json")

        # Load history
        try:
            if os.path.exists(history_file):
                with open(history_file, 'r') as f:
                    self.clipboard_history = json.load(f)
                print(f"📂 Loaded {len(self.clipboard_history)} history items")
        except Exception as e:
            print(f"Error loading history: {e}")
            self.clipboard_history = []

        # Load snippets
        try:
            if os.path.exists(snippets_file):
                with open(snippets_file, 'r') as f:
                    self.snippet_folders = json.load(f)
                print(f"📁 Loaded snippet folders")
        except Exception as e:
            print(f"Error loading snippets: {e}")
            self.snippet_folders = {}

        # Update menu with loaded data
        self.update_menu()

    def save_data(self):
        """Save clipboard history and snippets to storage."""
        history_file = os.path.join(self.data_dir, "history.json")
        snippets_file = os.path.join(self.data_dir, "snippets.json")

        try:
            # Save history
            with open(history_file, 'w') as f:
                json.dump(self.clipboard_history, f, indent=2)

            # Save snippets
            with open(snippets_file, 'w') as f:
                json.dump(self.snippet_folders, f, indent=2)

        except Exception as e:
            print(f"Error saving data: {e}")


if __name__ == "__main__":
    # For testing purposes
    app = ClipboardManager()
    app.run()
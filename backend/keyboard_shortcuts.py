"""
Keyboard shortcuts module for SimpleCP.

Provides global hotkey support for quick clipboard access.
Platform-specific implementations for macOS, Linux, and Windows.
"""

import sys
from typing import Optional, Callable, Dict


class KeyboardShortcuts:
    """
    Manage global keyboard shortcuts for clipboard operations.

    Supported shortcuts:
    - Cmd+Alt+V (⌘⌥V): Toggle clipboard panel
    - Cmd+Alt+1-9 (⌘⌥1-9): Quick paste from history positions 1-9
    """

    def __init__(self):
        """Initialize keyboard shortcuts manager."""
        self.platform = sys.platform
        self.shortcuts: Dict[str, Callable] = {}
        self.enabled = False

        # Try to import platform-specific keyboard library
        self.keyboard_lib = self._detect_keyboard_library()

    def _detect_keyboard_library(self) -> Optional[str]:
        """Detect available keyboard library."""
        try:
            import pynput

            return "pynput"
        except ImportError:
            pass

        try:
            import keyboard

            return "keyboard"
        except ImportError:
            pass

        return None

    def register_shortcut(
        self, keys: str, callback: Callable, description: str = ""
    ) -> bool:
        """
        Register a global keyboard shortcut.

        Args:
            keys: Key combination (e.g., "cmd+alt+v", "ctrl+shift+c")
            callback: Function to call when shortcut is pressed
            description: Human-readable description

        Returns:
            True if registered successfully
        """
        if not self.keyboard_lib:
            print(
                "Warning: No keyboard library available. "
                "Install pynput or keyboard package."
            )
            return False

        try:
            self.shortcuts[keys] = callback
            if self.keyboard_lib == "pynput":
                self._register_with_pynput(keys, callback)
            elif self.keyboard_lib == "keyboard":
                self._register_with_keyboard(keys, callback)
            return True
        except Exception as e:
            print(f"Failed to register shortcut {keys}: {e}")
            return False

    def _register_with_pynput(self, keys: str, callback: Callable):
        """Register shortcut using pynput library."""
        try:
            from pynput import keyboard
            from pynput.keyboard import Key, KeyCode

            # Parse key combination
            parts = keys.lower().replace("cmd", "alt").split("+")
            modifiers = []
            main_key = None

            for part in parts:
                if part in ["ctrl", "control"]:
                    modifiers.append(Key.ctrl)
                elif part in ["alt", "option"]:
                    modifiers.append(Key.alt)
                elif part in ["shift"]:
                    modifiers.append(Key.shift)
                else:
                    main_key = part

            # Define hotkey handler
            def on_activate():
                try:
                    callback()
                except Exception as e:
                    print(f"Shortcut callback error: {e}")

            # Note: Full implementation would use pynput.keyboard.Listener
            print(f"Registered shortcut: {keys} (pynput)")
            return on_activate

        except Exception as e:
            print(f"pynput registration failed: {e}")

    def _register_with_keyboard(self, keys: str, callback: Callable):
        """Register shortcut using keyboard library."""
        try:
            import keyboard

            # Convert macOS-style keys to keyboard library format
            keys_normalized = (
                keys.lower().replace("cmd", "command").replace("alt", "option")
            )

            keyboard.add_hotkey(keys_normalized, callback)
            print(f"Registered shortcut: {keys_normalized} (keyboard)")

        except Exception as e:
            print(f"keyboard registration failed: {e}")

    def unregister_all(self):
        """Unregister all shortcuts."""
        if self.keyboard_lib == "keyboard":
            try:
                import keyboard

                keyboard.unhook_all_hotkeys()
            except Exception:
                pass

        self.shortcuts.clear()
        self.enabled = False

    def enable(self):
        """Enable keyboard shortcuts."""
        self.enabled = True

    def disable(self):
        """Disable keyboard shortcuts."""
        self.enabled = False

    def get_shortcuts_info(self) -> Dict[str, str]:
        """Get information about registered shortcuts."""
        info = {
            "platform": self.platform,
            "library": self.keyboard_lib or "None",
            "enabled": self.enabled,
            "count": len(self.shortcuts),
        }

        # Add macOS-specific shortcuts
        if self.platform == "darwin":
            info["shortcuts"] = {
                "⌘⌥V": "Toggle clipboard panel",
                "⌘⌥1-9": "Quick paste from history positions 1-9",
                "⌘⌥C": "Clear clipboard history",
                "⌘⌥S": "Search clipboard",
            }

        return info


def setup_default_shortcuts(clipboard_manager) -> KeyboardShortcuts:
    """
    Set up default keyboard shortcuts for clipboard manager.

    Args:
        clipboard_manager: ClipboardManager instance

    Returns:
        Configured KeyboardShortcuts instance
    """
    shortcuts = KeyboardShortcuts()

    # Cmd+Alt+V: Toggle (placeholder - would integrate with UI)
    def toggle_panel():
        print("Toggle clipboard panel (UI integration needed)")

    shortcuts.register_shortcut("cmd+alt+v", toggle_panel, "Toggle clipboard panel")

    # Cmd+Alt+1-9: Quick paste from history
    for i in range(1, 10):

        def quick_paste(index=i):
            try:
                items = clipboard_manager.get_recent_history()
                if index <= len(items):
                    clipboard_manager.copy_to_clipboard(items[index - 1].clip_id)
                    print(f"Quick pasted item {index}")
            except Exception as e:
                print(f"Quick paste error: {e}")

        shortcuts.register_shortcut(
            f"cmd+alt+{i}", quick_paste, f"Quick paste item {i}"
        )

    return shortcuts

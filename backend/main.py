#!/usr/bin/env python3
"""
SimpleCP - Simple macOS Clipboard Manager
Entry point for the application.

Run with: python3 main.py
"""

import sys
import os

# Add the project root to Python path
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, project_root)

from api.server import run_server  # noqa: E402


def main():
    """Main application entry point."""
    try:
        print("🚀 Starting SimpleCP API Server...")
        print("📋 Server running on http://localhost:8000")
        print("📖 API docs available at http://localhost:8000/docs")
        run_server(host="127.0.0.1", port=8000)
    except KeyboardInterrupt:
        print("\n👋 SimpleCP server stopped by user")
    except Exception as e:
        print(f"❌ Error starting SimpleCP server: {e}")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Generate test data for clipboard history."""
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from clipboard_manager import ClipboardManager


def generate_test_data():
    """Generate sample clipboard data for testing."""
    manager = ClipboardManager()

    # Sample clipboard history
    test_clips = [
        "https://github.com/example/repo",
        "def hello_world():\n    print('Hello, World!')",
        "user@example.com",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        "SELECT * FROM users WHERE id = 1;",
        "import numpy as np\nimport pandas as pd",
        '{"name": "John", "age": 30, "city": "New York"}',
        "curl -X GET https://api.example.com/data",
        "ssh user@server.example.com",
        "Meeting at 3pm tomorrow - don't forget!",
    ]

    print("Adding clipboard history items...")
    for i, content in enumerate(test_clips, 1):
        manager.add_clip(content)
        print(f"  [{i}/{len(test_clips)}] Added: {content[:50]}...")

    # Sample snippets
    snippets = [
        {
            "content": "#!/bin/bash\necho 'Hello from bash'",
            "name": "Bash Hello",
            "folder": "Scripts",
            "tags": ["bash", "script"],
        },
        {
            "content": "print('Python snippet')",
            "name": "Python Print",
            "folder": "Code",
            "tags": ["python"],
        },
        {
            "content": "SELECT id, name FROM users LIMIT 10;",
            "name": "List Users",
            "folder": "SQL",
            "tags": ["sql", "query"],
        },
        {
            "content": "docker run -it ubuntu:latest",
            "name": "Ubuntu Container",
            "folder": "Docker",
            "tags": ["docker", "container"],
        },
        {
            "content": "git commit -am 'Quick commit'",
            "name": "Git Quick Commit",
            "folder": "Git",
            "tags": ["git", "version-control"],
        },
    ]

    print("\nAdding snippets...")
    for i, snippet in enumerate(snippets, 1):
        manager.add_snippet_direct(
            snippet["content"], snippet["name"], snippet["folder"], snippet["tags"]
        )
        print(f"  [{i}/{len(snippets)}] Added snippet: {snippet['name']}")

    stats = manager.get_stats()
    print(f"\nTest data generated successfully!")
    print(f"  History items: {stats['history_count']}")
    print(f"  Snippets: {stats['snippet_count']}")
    print(f"  Folders: {stats['folder_count']}")


if __name__ == "__main__":
    generate_test_data()

# SimpleCP - Simple macOS Clipboard Manager

A lightweight macOS menu bar clipboard manager with snippet folders, built because existing solutions are subscription-based or over-developed.

## Features

🚀 **Core Functionality**
- Menu bar clipboard manager for macOS
- Automatic clipboard history tracking
- Organized snippet folders for reusable text
- Search across history and snippets
- Keyboard shortcuts for quick access

📁 **Snippet Folders**
- Organize frequently used text snippets
- Nested folder structure support
- Quick paste from organized collections
- Import/export functionality

🎯 **Simple & Clean**
- No subscriptions or complex features
- Lightweight Python implementation
- JSON-based storage (easy backup)
- MIT licensed and open source

## Installation

### Prerequisites
- macOS 10.13+
- Python 3.7+

### Setup
```bash
# Clone the repository
git clone <repository-url>
cd clipboard_manager

# Install dependencies
pip3 install rumps pyperclip

# Run the application
python3 main.py
```

## Architecture

### Project Structure
```
clipboard_manager/
├── main.py                 # Entry point
├── clipboard_manager.py    # Main app class
├── stores/
│   ├── __init__.py
│   ├── history_store.py    # Recent clipboard history
│   ├── snippet_store.py    # Organized snippets
│   └── clipboard_item.py   # Data model
├── ui/
│   ├── __init__.py
│   └── menu_builder.py     # Menu generation
├── settings.py             # Configuration management
├── data/
│   ├── history.json        # Recent items (gitignored)
│   ├── snippets.json       # Snippet folders (gitignored)
│   └── config.json         # App settings (gitignored)
└── assets/
    └── icon.png           # Menu bar icon
```

### Core Components

- **ClipboardManager**: Main rumps.App class managing the menu bar app
- **HistoryStore**: Manages recent clipboard items with deduplication
- **SnippetStore**: Handles folder-based snippet organization
- **MenuBuilder**: Generates dynamic menus for history and snippets
- **Settings**: JSON-based configuration and persistence

## Development Status

### ✅ Completed
- Requirements analysis
- Technology research (analyzed Flycut codebase)
- Architecture design
- Project structure setup
- Repository initialization

### 🔄 Current Phase: Implementation
- [ ] Basic framework setup
- [ ] Clipboard monitoring
- [ ] Menu bar interface
- [ ] History management
- [ ] Snippet folders system
- [ ] Search functionality
- [ ] Settings/preferences

## Development Workflow

This project is designed for collaboration between local Claude Code and web Claude:

1. **Local Development** (Claude Code): System integration, testing, file operations
2. **Web Development** (Online Claude): Core logic implementation, algorithms
3. **Shared Repository**: Single source of truth for collaboration

### Collaboration Guidelines

For **Web Claude**:
```bash
# To continue development:
git pull origin main
# Make your changes
git add .
git commit -m "feat: description of changes"
git push origin main
```

For **Claude Code**:
- Handle system-specific operations
- Test application functionality
- Manage file operations and Git workflow

## Technology Stack

- **rumps**: Python library for macOS menu bar applications
- **pyperclip**: Cross-platform clipboard operations
- **JSON**: Simple data persistence
- **Python 3**: Core implementation language

## Inspiration

Based on analysis of [Flycut](https://github.com/TermiT/Flycut), an excellent open-source clipboard manager. Our implementation provides:

- **Simpler architecture**: Python vs 58k lines of Objective-C
- **Snippet folders**: Built-in folder organization (missing in Flycut)
- **Easy customization**: JSON configuration vs complex preferences
- **Modern approach**: Designed for current macOS versions

## License

MIT License - Build, modify, and distribute freely.

## Contributing

1. Check current implementation status in `docs/IMPLEMENTATION_STATUS.md`
2. Follow the development workflow above
3. Test on macOS before pushing
4. Update documentation for new features

---

**Need to use API credits?** Continue development in web Claude with the collaboration workflow above!
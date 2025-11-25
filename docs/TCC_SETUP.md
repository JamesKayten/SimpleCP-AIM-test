# TCC Configuration for AI Collaboration Management

## Overview

TCC (Terminal Control Center) has been configured with persistent access to the AI Collaboration Management framework. This ensures TCC always knows where to find the rules, protocols, and project context when starting a new terminal session.

## Configuration Files

The following files have been set up in the user's home directory:

### 1. `~/.tccrc` (5.8 KB)
TCC configuration file with:
- Environment variables for framework paths
- Helper functions for common operations
- Command aliases for quick access

### 2. `~/tcc-init.sh` (5.9 KB)
Initialization script that:
- Loads TCC configuration
- Verifies/clones framework repository
- Checks for updates
- Validates project context
- Displays available commands

### 3. `~/TCC_INITIALIZATION_GUIDE.md` (9.2 KB)
Complete documentation including:
- System architecture
- Startup protocol
- Available commands
- Troubleshooting guide
- Best practices

### 4. `~/TCC_QUICK_START.md` (1.4 KB)
One-page reference for quick setup

### 5. `~/.bashrc` (Modified)
Added automatic sourcing of `~/.tccrc` on terminal startup

## For TCC: First Command

When starting a new terminal session:

```bash
source ~/tcc-init.sh
```

This provides immediate access to:
- AI Collaboration Management framework rules
- Current project BOARD.md
- Environment variables for all paths
- Helper commands

## Available Commands

After initialization:

```bash
tcc-status   # Framework and project status
tcc-board    # View BOARD.md
tcc-rules    # Display General AI Rules
tcc-startup  # Display Startup Protocol
tcc-setup    # Configure for current project
tcc-sync     # Update framework
```

## Framework Location

The AI-Collaboration-Management repository is located at:
```
~/AI-Collaboration-Management
```

This repository contains:
- `rules/GENERAL_AI_RULES.md` - Universal AI behavioral standards
- `rules/STARTUP_PROTOCOL.md` - Mandatory 5-step initialization
- `rules/RULE_IMPROVEMENTS.md` - Continuous learning from failures
- `templates/` - Project-specific rule templates

## Integration with This Project

When working in the SimpleCP project:

1. Navigate to project directory:
   ```bash
   cd ~/SimpleCP
   ```

2. Initialize TCC:
   ```bash
   source ~/tcc-init.sh
   ```

3. Check project status:
   ```bash
   tcc-status
   ```

4. View current tasks:
   ```bash
   tcc-board
   ```

The configuration automatically detects the current project and provides access to:
- `.ai/BOARD.md` (if it exists)
- Project-specific rules
- Git status
- Running processes

## Benefits

✅ **No Manual Path Lookup** - TCC always knows where to find framework files
✅ **Automatic Updates** - Init script checks for framework updates
✅ **Project Awareness** - Automatically detects current project context
✅ **Quick Access Commands** - One-word commands for common operations
✅ **Persistent Configuration** - Survives terminal restarts
✅ **Holistic Approach Enabled** - Follows mandatory startup protocol

## Troubleshooting

If TCC reports framework not found:
```bash
# Reinitialize
source ~/tcc-init.sh

# Or manually check
ls -la ~/AI-Collaboration-Management
```

If commands not available:
```bash
# Reload configuration
source ~/.tccrc
```

## Documentation

Full documentation is available at:
- `~/TCC_INITIALIZATION_GUIDE.md` - Complete guide
- `~/TCC_QUICK_START.md` - Quick reference

---

**Created:** 2025-11-22
**Purpose:** Solve TCC's "where to find the rules" problem
**Status:** ✅ Fully operational
**Repository:** https://github.com/JamesKayten/AI-Collaboration-Management

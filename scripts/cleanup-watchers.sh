#!/bin/bash

# cleanup-watchers.sh - Clean up stuck watcher processes and temporary files
# Part of AI Collaboration Management (AICM) framework

set -e

echo "🧹 AICM Watcher Cleanup"
echo "======================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
REPO_NAME=$(basename "$REPO_ROOT")

echo -e "${BLUE}Repository:${RESET} $REPO_NAME"
echo -e "${BLUE}Location:${RESET} $REPO_ROOT"
echo ""

# Function to check if process is running
is_running() {
    local pattern="$1"
    pgrep -f "$pattern" >/dev/null 2>&1
}

# Function to kill processes matching pattern
kill_processes() {
    local pattern="$1"
    local description="$2"

    if is_running "$pattern"; then
        echo -e "${YELLOW}Killing ${description}...${RESET}"
        pkill -f "$pattern" && echo -e "${GREEN}✓ Stopped ${description}${RESET}"
    else
        echo -e "${GREEN}✓ No ${description} running${RESET}"
    fi
}

# 1. Kill watcher processes
echo "Checking for running watcher processes..."
kill_processes "watch-build\.sh" "build watchers"
kill_processes "watch-all\.sh" "unified watchers"
kill_processes "aim-launcher\.sh" "launcher processes"

echo ""

# 2. Clean up temporary files
echo "Cleaning temporary files..."

# Branch watcher state files
BRANCH_FILES=$(ls /tmp/branch-watcher-*.pending /tmp/branch-watcher-*.state 2>/dev/null || true)
if [ -n "$BRANCH_FILES" ]; then
    echo -e "${YELLOW}Removing branch watcher files:${RESET}"
    for file in $BRANCH_FILES; do
        echo "  - $(basename "$file")"
        rm -f "$file"
    done
    echo -e "${GREEN}✓ Branch watcher files cleaned${RESET}"
else
    echo -e "${GREEN}✓ No branch watcher files to clean${RESET}"
fi

# Board watcher log files
BOARD_FILES=$(ls /tmp/board-watcher*.log 2>/dev/null || true)
if [ -n "$BOARD_FILES" ]; then
    echo -e "${YELLOW}Removing board watcher files:${RESET}"
    for file in $BOARD_FILES; do
        echo "  - $(basename "$file")"
        rm -f "$file"
    done
    echo -e "${GREEN}✓ Board watcher files cleaned${RESET}"
else
    echo -e "${GREEN}✓ No board watcher files to clean${RESET}"
fi

# Build watcher files
BUILD_FILES=$(ls /tmp/build-watcher*.log /tmp/build-watcher*.state 2>/dev/null || true)
if [ -n "$BUILD_FILES" ]; then
    echo -e "${YELLOW}Removing build watcher files:${RESET}"
    for file in $BUILD_FILES; do
        echo "  - $(basename "$file")"
        rm -f "$file"
    done
    echo -e "${GREEN}✓ Build watcher files cleaned${RESET}"
else
    echo -e "${GREEN}✓ No build watcher files to clean${RESET}"
fi

echo ""

# 3. Verify cleanup
echo "Verifying cleanup..."

REMAINING_PROCESSES=$(pgrep -f "watch-.*\.sh" 2>/dev/null || true)
if [ -n "$REMAINING_PROCESSES" ]; then
    echo -e "${RED}⚠️ Some watcher processes still running:${RESET}"
    ps -p $REMAINING_PROCESSES -o pid,command 2>/dev/null || true
    echo -e "${YELLOW}You may need to kill them manually with: sudo kill $REMAINING_PROCESSES${RESET}"
else
    echo -e "${GREEN}✓ All watcher processes stopped${RESET}"
fi

REMAINING_FILES=$(ls /tmp/*watcher* 2>/dev/null || true)
if [ -n "$REMAINING_FILES" ]; then
    echo -e "${YELLOW}⚠️ Some watcher files remain:${RESET}"
    echo "$REMAINING_FILES"
else
    echo -e "${GREEN}✓ All watcher files cleaned${RESET}"
fi

echo ""
echo -e "${GREEN}🎉 Cleanup complete!${RESET}"
echo ""
echo -e "${BLUE}To restart watchers on macOS:${RESET} ./scripts/aim-launcher.sh"
echo -e "${BLUE}To check status:${RESET} ps aux | grep 'watch-.*\.sh'"
#!/bin/bash
# Works Ready Hook - AUTO-EXECUTES validation and merge

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT")
PENDING_FILE="/tmp/branch-watcher-${REPO_NAME}.pending"

cd "$REPO_ROOT" 2>/dev/null || exit 0

# Find OCC branch to validate
BRANCH=""
if [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
    BRANCH=$(head -1 "$PENDING_FILE" | awk '{print $1}')
fi

if [ -z "$BRANCH" ]; then
    # Check for remote OCC branches
    git fetch origin --quiet 2>/dev/null
    CURRENT=$(git branch --show-current)
    BRANCH=$(git branch -r | grep 'origin/claude/' | grep -v "origin/$CURRENT" | head -1 | sed 's/.*origin\///' | xargs)
fi

echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "WORKS READY - AUTO-EXECUTE MODE"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

if [ -z "$BRANCH" ]; then
    echo "STATUS: No OCC branches found to merge."
    echo ""
    echo "INSTRUCTION: Report to user that there are no pending branches to validate."
    echo "Do NOT ask questions. Just report the status."
    echo "═══════════════════════════════════════════════════════════════════════════════"
    exit 0
fi

echo "INSTRUCTION: Execute /works-ready IMMEDIATELY for branch: $BRANCH"
echo "Do NOT ask questions. Just execute the slash command."
echo "═══════════════════════════════════════════════════════════════════════════════"

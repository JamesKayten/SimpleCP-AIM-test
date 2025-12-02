#!/bin/bash
# Session Start Display - Informative status for deployed AIM repos

# Colors for terminal output (to stderr)
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT" 2>/dev/null || echo "UNKNOWN")

cd "$REPO_ROOT" || exit 1

echo "" >&2
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${RESET}" >&2
echo -e "${BOLD}${CYAN}    AIM DEPLOYED REPOSITORY: $REPO_NAME" >&2
echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${RESET}" >&2

# Quick sync check
git fetch origin --quiet 2>/dev/null || true

# Check for OCC branches
OCC_BRANCHES=$(git branch -r | grep 'origin/claude/' 2>/dev/null | wc -l | xargs)

# Show branch status
if [ "$OCC_BRANCHES" -gt 0 ]; then
    echo -e "${YELLOW}📋 $OCC_BRANCHES OCC branch(es) found - use 'wr' to process${RESET}" >&2
    echo "SessionStart:startup hook success: FOUND_BRANCHES"
    echo "Status: $OCC_BRANCHES OCC branch(es) found"
    echo "Action: Use 'wr' or '/works-ready' to process"
else
    echo -e "${GREEN}✓ No pending OCC branches${RESET}" >&2
    echo "SessionStart:startup hook success: NO_BRANCHES"
    echo "Status: No pending OCC branches"
    echo "Action: Standing by"
fi

# Watcher management
if [ -f "$REPO_ROOT/scripts/watch-all.sh" ]; then
    PID_FILE="/tmp/aim-watcher-${REPO_NAME}.pid"
    LOG_FILE="/tmp/aim-watcher-${REPO_NAME}.log"

    if [ ! -f "$PID_FILE" ] || ! ps -p "$(cat "$PID_FILE" 2>/dev/null)" >/dev/null 2>&1; then
        # Start watcher
        nohup "$REPO_ROOT/scripts/watch-all.sh" >"$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"
        echo -e "${GREEN}🚀 AIM Watcher STARTED (background)${RESET}" >&2
    else
        echo -e "${GREEN}✓ AIM Watcher already running${RESET}" >&2
    fi

    echo -e "${BLUE}📡 Monitor: ./scripts/watcher-status.sh${RESET}" >&2
    echo -e "${BLUE}📋 Logs: tail -f $LOG_FILE${RESET}" >&2
else
    echo -e "${YELLOW}⚠️  No watcher scripts found${RESET}" >&2
fi

echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════${RESET}" >&2
echo "" >&2

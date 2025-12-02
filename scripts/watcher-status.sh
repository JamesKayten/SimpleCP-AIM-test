#!/bin/bash
# Show AIM watcher status for deployed repos

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT" 2>/dev/null || echo "UNKNOWN")
PID_FILE="/tmp/aim-watcher-${REPO_NAME}.pid"
LOG_FILE="/tmp/aim-watcher-${REPO_NAME}.log"

echo "AIM Watcher Status for $REPO_NAME:"
echo "================================"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Watcher is RUNNING (PID: $PID)"
        echo "📋 Log: $LOG_FILE"
        echo "🔗 View: tail -f $LOG_FILE"
    else
        echo "❌ Watcher process not found (stale PID file)"
        rm -f "$PID_FILE"
    fi
else
    echo "❌ No watcher PID file found"
fi

echo ""
echo "Commands:"
echo "  ./scripts/watch-all.sh          - Start watcher (foreground)"
echo "  ./scripts/watcher-status.sh     - Show this status"
echo "  ./scripts/cleanup-watchers.sh   - Stop all watchers"

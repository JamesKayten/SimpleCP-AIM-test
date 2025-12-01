#!/bin/bash
# Git Status and Sync Validation Tests

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SIMPLECP_ROOT="$REPO_ROOT"
AICM_ROOT="${AICM_ROOT:-}"
TEST_NAME="Git Status & Sync Validation"
ERRORS=0; WARNINGS=0; PASSED=0

source "$(dirname "$0")/common.sh"
header "$TEST_NAME"

# Test 1: Git repository status
echo "Test 1: Git Repository Status"
cd "$REPO_ROOT"
if [ -d .git ]; then
    pass "Git repository initialized"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    info "Current branch: $BRANCH"
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        pass "No uncommitted changes"
    else
        warn "Uncommitted changes detected"
    fi
    UNTRACKED=$(git ls-files --others --exclude-standard)
    [ -z "$UNTRACKED" ] && pass "No untracked files" || warn "Untracked files detected"
else
    fail "Not a git repository"
fi
echo ""

# Test 2: Recent commit verification
echo "Test 2: Recent Commit Verification"
cd "$REPO_ROOT"
if git log --oneline -20 | grep -i "reorganize\|organization" > /dev/null; then
    pass "Reorganization commit found"
    info "Latest commit: $(git log -1 --pretty=format:'%h - %s')"
else
    warn "Recent reorganization commit not found"
fi
echo ""

# Test 3: Sync script existence
echo "Test 3: AICM Sync Scripts"
SYNC_FROM="$REPO_ROOT/scripts/sync/sync-from-aicm.sh"
SYNC_TO="$REPO_ROOT/scripts/sync/sync-to-aicm.sh"

for script in "$SYNC_FROM" "$SYNC_TO"; do
    if [ -f "$script" ]; then
        pass "$(basename $script) exists"
        [ -x "$script" ] && pass "$(basename $script) is executable" || fail "$(basename $script) NOT executable"
    else
        fail "Missing: $script"
    fi
done
echo ""

# Test 4: AICM repository check
echo "Test 4: AICM Repository Integration"
if [ -d "$AICM_ROOT" ]; then
    pass "AICM repository exists"
    cd "$AICM_ROOT"
    [ -d .git ] && pass "AICM is a git repository" || warn "AICM not a git repository"
else
    warn "AICM repository not found (expected if not syncing)"
fi
echo ""

# Test 5: Git configuration
echo "Test 5: Git Configuration"
cd "$REPO_ROOT"
[ -n "$(git config user.name 2>/dev/null)" ] && info "Git user.name configured" || warn "Git user.name not configured"
[ -n "$(git config user.email 2>/dev/null)" ] && info "Git user.email configured" || warn "Git user.email not configured"
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null)
[ -n "$REMOTE_URL" ] && pass "Remote origin configured" || warn "No remote origin"
echo ""

# Test 6: File permissions
echo "Test 6: File Permissions"
for script in scripts/backend/kill_backend.sh scripts/sync/sync-from-aicm.sh scripts/sync/sync-to-aicm.sh scripts/tcc/install-tcc.sh; do
    [ -f "$REPO_ROOT/$script" ] && [ -x "$REPO_ROOT/$script" ] && pass "Executable: $script"
done
echo ""

print_summary "$TEST_NAME"
exit $?

#!/bin/bash
# TCC Branch Validation Script
# Gathers all info needed for works-ready decision
# Usage: ./scripts/tcc-validate-branch.sh [branch-name]

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_ROOT")
PENDING_FILE="/tmp/branch-watcher-${REPO_NAME}.pending"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

cd "$REPO_ROOT"

# Get branch to validate
if [ -n "$1" ]; then
    BRANCH="$1"
elif [ -f "$PENDING_FILE" ] && [ -s "$PENDING_FILE" ]; then
    BRANCH=$(head -1 "$PENDING_FILE" | awk '{print $1}')
else
    # Find OCC branches (claude/* branches that aren't current)
    CURRENT=$(git branch --show-current)
    BRANCH=$(git branch -r | grep 'origin/claude/' | grep -v "$CURRENT" | head -1 | sed 's/origin\///' | xargs)
fi

if [ -z "$BRANCH" ]; then
    echo -e "${YELLOW}NO OCC BRANCHES FOUND${RESET}"
    echo "All branches are at main. Nothing to validate."
    exit 0
fi

echo -e "${BOLD}================================================================================${RESET}"
echo -e "${BOLD}TCC VALIDATION REPORT${RESET}"
echo -e "${BOLD}================================================================================${RESET}"
echo ""
echo -e "Repository: ${GREEN}${BOLD}$REPO_NAME${RESET}"
echo -e "Branch:     ${CYAN}${BOLD}$BRANCH${RESET}"
echo ""

# Fetch latest
git fetch origin "$BRANCH" --quiet 2>/dev/null || true
git fetch origin main --quiet 2>/dev/null

# Get commit info
BRANCH_HEAD=$(git rev-parse "origin/$BRANCH" 2>/dev/null || echo "NOT_FOUND")
MAIN_HEAD=$(git rev-parse origin/main 2>/dev/null)

if [ "$BRANCH_HEAD" = "NOT_FOUND" ]; then
    echo -e "${RED}ERROR: Branch $BRANCH not found on remote${RESET}"
    exit 1
fi

echo -e "${BOLD}Commits:${RESET}"
echo -e "  Branch HEAD: ${CYAN}${BRANCH_HEAD:0:7}${RESET}"
echo -e "  Main HEAD:   ${CYAN}${MAIN_HEAD:0:7}${RESET}"
echo ""

# Show commits to merge
COMMITS_AHEAD=$(git log origin/main..origin/$BRANCH --oneline 2>/dev/null)
if [ -z "$COMMITS_AHEAD" ]; then
    echo -e "${YELLOW}No new commits on $BRANCH (already merged or same as main)${RESET}"
    echo ""
    echo -e "${BOLD}RESULT: NOTHING TO MERGE${RESET}"
    exit 0
fi

echo -e "${BOLD}Commits to merge:${RESET}"
echo "$COMMITS_AHEAD" | while read line; do
    echo -e "  ${CYAN}$line${RESET}"
done
echo ""

# File size compliance check
echo -e "${BOLD}File Size Compliance:${RESET}"
COMPLIANCE_SCRIPT="$REPO_ROOT/scripts/tcc-file-compliance.sh"
if [ -f "$COMPLIANCE_SCRIPT" ]; then
    VIOLATIONS=$("$COMPLIANCE_SCRIPT" main 2>&1) || true
    if echo "$VIOLATIONS" | grep -q "VIOLATION"; then
        echo -e "${RED}VIOLATIONS FOUND:${RESET}"
        echo "$VIOLATIONS" | grep "VIOLATION"
        echo ""
        echo -e "${BOLD}${RED}RESULT: BLOCKED - Fix violations before merge${RESET}"
        exit 1
    else
        echo -e "  ${GREEN}✓ All files within size limits${RESET}"
    fi
else
    echo -e "  ${YELLOW}⚠ No compliance script found (skipping)${RESET}"
fi
echo ""

# Show files changed
echo -e "${BOLD}Files changed:${RESET}"
git diff --name-only origin/main...origin/$BRANCH 2>/dev/null | while read file; do
    echo -e "  ${CYAN}$file${RESET}"
done
echo ""

echo -e "${BOLD}================================================================================${RESET}"
echo -e "${BOLD}${GREEN}VALIDATION PASSED - READY TO MERGE${RESET}"
echo -e "${BOLD}================================================================================${RESET}"
echo ""
echo -e "Run these commands to complete merge:"
echo ""
echo -e "  ${CYAN}git checkout main${RESET}"
echo -e "  ${CYAN}git merge origin/$BRANCH${RESET}"
echo -e "  ${CYAN}git push origin main${RESET}"
echo -e "  ${CYAN}git push origin --delete $BRANCH${RESET}"
echo ""

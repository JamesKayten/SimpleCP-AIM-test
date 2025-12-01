#!/bin/bash
# Common utilities for validation scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Counters (initialize if not set)
ERRORS=${ERRORS:-0}
WARNINGS=${WARNINGS:-0}
PASSED=${PASSED:-0}

# Helper functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

header() {
    echo "=========================================="
    echo "$1"
    echo "=========================================="
    echo ""
}

# Print test summary
print_summary() {
    local test_name="${1:-Test}"
    echo ""
    echo "=========================================="
    echo "$test_name Summary"
    echo "=========================================="
    echo -e "Passed:   ${GREEN}$PASSED${NC}"
    echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
    echo -e "Errors:   ${RED}$ERRORS${NC}"
    echo ""
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}FAILED${NC}"
        return 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}PASSED WITH WARNINGS${NC}"
        return 0
    else
        echo -e "${GREEN}PASSED${NC}"
        return 0
    fi
}

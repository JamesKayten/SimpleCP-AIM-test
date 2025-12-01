#!/bin/bash
# Documentation Integrity Validation Tests

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_NAME="Documentation Integrity Validation"
ERRORS=0; WARNINGS=0; PASSED=0

source "$(dirname "$0")/common.sh"
header "$TEST_NAME"

# Test 1: README.md references
echo "Test 1: README.md Internal References"
cd "$REPO_ROOT"
grep -q "localhost:8000" README.md && pass "README uses correct port (8000)" || warn "Port 8000 not found in README"

for link in docs/API.md docs/UI_UX_SPECIFICATION_v3.md docs/USER_GUIDE.md docs/BOARD.md docs/AI_COLLABORATION_FRAMEWORK.md docs/tcc/TCC_WORKFLOW_GUIDE.md docs/tcc/README_TCC_INSTALLATION.md docs/reports/INTEGRATION_TEST_REPORT.md; do
    if grep -q "$link" README.md; then
        [ -f "$REPO_ROOT/$link" ] && pass "Link valid: $link" || fail "Broken link: $link"
    fi
done
echo ""

# Test 2: Check for broken internal links in docs
echo "Test 2: Documentation Cross-References"
for md_file in $(find "$REPO_ROOT/docs" -name "*.md" -type f 2>/dev/null); do
    LINKS=$(grep -oP '\[([^\]]+)\]\(([^)]+)\)' "$md_file" 2>/dev/null | grep -oP '\(([^)]+)\)' | tr -d '()' || true)
    for link in $LINKS; do
        [[ "$link" =~ ^https?:// ]] && continue
        [[ "$link" =~ ^# ]] && continue
        [ ! -f "$REPO_ROOT/docs/$link" ] && [ ! -f "$REPO_ROOT/$link" ] && warn "Broken: $(basename $md_file) -> $link"
    done
done
pass "Cross-reference check completed"
echo ""

# Test 3: Navigation guide
echo "Test 3: Navigation Guide"
if [ -f "$REPO_ROOT/docs/README_ORGANIZATION.md" ]; then
    pass "Navigation guide exists"
    grep -q "/tcc/" "$REPO_ROOT/docs/README_ORGANIZATION.md" && pass "References TCC" || warn "Missing TCC reference"
    grep -q "/reports/" "$REPO_ROOT/docs/README_ORGANIZATION.md" && pass "References reports" || warn "Missing reports reference"
else
    fail "Navigation guide missing"
fi
echo ""

# Test 4: Script paths
echo "Test 4: Script Path References"
for script in scripts/backend/kill_backend.sh scripts/sync/sync-from-aicm.sh scripts/sync/sync-to-aicm.sh scripts/tcc/install-tcc.sh; do
    grep -q "$script" README.md && pass "Script referenced: $script" || warn "Script not referenced: $script"
done
echo ""

# Test 5: Outdated content
echo "Test 5: Outdated Content Detection"
for pattern in "rules/" "tcc-config-files/"; do
    grep -r "$pattern" README.md 2>/dev/null | grep -v "framework/$pattern" > /dev/null && warn "Old reference: $pattern"
done
pass "Outdated content check completed"
echo ""

# Test 6: Technical accuracy
echo "Test 6: Technical Accuracy"
grep -q "main.py" README.md && pass "Backend entry point documented" || warn "main.py not mentioned"
(grep -q "Package.swift" README.md || grep -q "swift run" README.md) && pass "Frontend documented" || warn "Frontend build not clear"
grep -qE "## .*Architecture" README.md && pass "Architecture section exists" || warn "Architecture section missing"
echo ""

print_summary "$TEST_NAME"
exit $?

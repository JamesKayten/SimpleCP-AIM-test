#!/bin/bash
# Repository Structure Validation Tests

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_NAME="Repository Structure Validation"
ERRORS=0; WARNINGS=0; PASSED=0

source "$(dirname "$0")/common.sh"
header "$TEST_NAME"

# Test 1: Core directories
echo "Test 1: Core Directories"
for dir in docs scripts templates tests examples framework .claude; do
    [ -d "$REPO_ROOT/$dir" ] && pass "Directory: $dir/" || fail "Missing: $dir/"
done
echo ""

# Test 2: Documentation organization
echo "Test 2: Documentation Organization"
for dir in docs/tcc docs/reports docs/framework; do
    [ -d "$REPO_ROOT/$dir" ] && pass "Doc dir: $dir/" || warn "Missing: $dir/"
done
echo ""

# Test 3: Scripts organization
echo "Test 3: Scripts Organization"
for dir in scripts/validation scripts/utilities; do
    [ -d "$REPO_ROOT/$dir" ] && pass "Scripts dir: $dir/" || fail "Missing: $dir/"
done
echo ""

# Test 4: Required files in root
echo "Test 4: Required Root Files"
for file in README.md .gitignore LICENSE; do
    [ -f "$REPO_ROOT/$file" ] && pass "File: $file" || fail "Missing: $file"
done
echo ""

# Test 5: Root cleanliness - old files should NOT exist
echo "Test 5: Root Directory Cleanliness"
for file in BOARD.md TASKS.md TCC_WORKFLOW_GUIDE.md MASTER_FRAMEWORK_STATUS.md CHANGELOG.md CONTRIBUTING.md ai; do
    [ ! -f "$REPO_ROOT/$file" ] && pass "Moved: $file" || fail "Should be moved: $file"
done
for dir in rules tcc-setup; do
    [ ! -d "$REPO_ROOT/$dir" ] && pass "Moved: $dir/" || fail "Should be moved: $dir/"
done
echo ""

# Test 6: Scripts are executable
echo "Test 6: Script Executability"
for script in scripts/validation/run_all_tests.sh scripts/validation/test_repository_structure.sh scripts/validation/test_documentation_integrity.sh scripts/validation/test_git_status.sh; do
    [ -f "$REPO_ROOT/$script" ] && [ -x "$REPO_ROOT/$script" ] && pass "Executable: $script" || warn "Not executable: $script"
done
echo ""

# Test 7: Documentation files moved correctly
echo "Test 7: Documentation Migration"
for file in docs/BOARD.md docs/TASKS.md docs/MASTER_FRAMEWORK_STATUS.md docs/CHANGELOG.md docs/CONTRIBUTING.md docs/tcc/TCC_WORKFLOW_GUIDE.md; do
    [ -f "$REPO_ROOT/$file" ] && pass "Moved: $file" || fail "NOT moved: $file"
done
echo ""

# Test 8: AI Framework structure
echo "Test 8: AI Framework Structure"
for dir in framework/rules framework/tcc-setup; do
    [ -d "$REPO_ROOT/$dir" ] && pass "Framework: $dir/" || fail "Missing: $dir/"
done
echo ""

# Test 9: Validation framework
echo "Test 9: Validation Framework"
[ -d "$REPO_ROOT/scripts/validation" ] && pass "Validation framework installed" || fail "Validation framework missing"
for script in run_all_tests.sh test_repository_structure.sh test_documentation_integrity.sh test_git_status.sh; do
    [ -f "$REPO_ROOT/scripts/validation/$script" ] && pass "Script: $script" || fail "Missing: $script"
done
echo ""

print_summary "$TEST_NAME"
exit $?

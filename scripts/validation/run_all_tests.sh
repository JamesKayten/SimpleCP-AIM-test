#!/bin/bash
# AICM Framework Validation - Master Test Runner

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$REPO_ROOT/scripts/validation"
REPORT_FILE="$REPO_ROOT/VALIDATION_REPORT.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

source "$(dirname "$0")/common.sh"

echo -e "${CYAN}==========================================\nAICM Framework Validation Suite\n==========================================\nRepository: SimpleCP\nTimestamp:  $TIMESTAMP\n==========================================${NC}\n"

# Initialize report
cat > "$REPORT_FILE" << EOF
# AICM Framework Validation Report
**Repository:** SimpleCP | **Date:** $TIMESTAMP | **Location:** $REPO_ROOT

---
## Test Results
EOF

TOTAL_ERRORS=0; TOTAL_WARNINGS=0; TESTS_PASSED=0; TESTS_FAILED=0

run_test() {
    local test_script=$1; local test_name=$2
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n${CYAN}Running: $test_name${NC}\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    OUTPUT=$($test_script 2>&1); EXIT_CODE=$?
    echo "$OUTPUT"
    ERRORS=$(echo "$OUTPUT" | grep "^Errors:" | awk '{print $2}' || echo "0")
    WARNINGS=$(echo "$OUTPUT" | grep "^Warnings:" | awk '{print $2}' || echo "0")
    TOTAL_ERRORS=$((TOTAL_ERRORS + ERRORS)); TOTAL_WARNINGS=$((TOTAL_WARNINGS + WARNINGS))

    echo -e "\n### $test_name\n" >> "$REPORT_FILE"
    if [ $EXIT_CODE -eq 0 ]; then
        [ "$WARNINGS" -eq 0 ] && { echo -e "${GREEN}✓ PASSED${NC}"; echo "**Status:** ✅ PASSED" >> "$REPORT_FILE"; } || { echo -e "${YELLOW}⚠ PASSED WITH WARNINGS${NC}"; echo "**Status:** ⚠️ PASSED WITH WARNINGS" >> "$REPORT_FILE"; }
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"; echo "**Status:** ❌ FAILED" >> "$REPORT_FILE"; ((TESTS_FAILED++))
    fi
    echo -e "**Errors:** $ERRORS | **Warnings:** $WARNINGS\n\n<details><summary>Details</summary>\n\n\`\`\`\n$OUTPUT\n\`\`\`\n</details>\n\n---\n" >> "$REPORT_FILE"
    return $EXIT_CODE
}

run_test "$SCRIPT_DIR/test_repository_structure.sh" "Repository Structure"
run_test "$SCRIPT_DIR/test_documentation_integrity.sh" "Documentation Integrity"
run_test "$SCRIPT_DIR/test_git_status.sh" "Git Status & Sync"

echo -e "\n${CYAN}==========================================\nValidation Summary\n==========================================${NC}"
echo -e "Tests Passed:    ${GREEN}$TESTS_PASSED${NC}\nTests Failed:    ${RED}$TESTS_FAILED${NC}\nTotal Errors:    ${RED}$TOTAL_ERRORS${NC}\nTotal Warnings:  ${YELLOW}$TOTAL_WARNINGS${NC}\n"

cat >> "$REPORT_FILE" << EOF
## Summary
| Metric | Count |
|--------|-------|
| Tests Passed | $TESTS_PASSED |
| Tests Failed | $TESTS_FAILED |
| Total Errors | $TOTAL_ERRORS |
| Total Warnings | $TOTAL_WARNINGS |

## Verdict
EOF

if [ $TESTS_FAILED -eq 0 ] && [ $TOTAL_ERRORS -eq 0 ]; then
    [ $TOTAL_WARNINGS -eq 0 ] && { echo -e "${GREEN}✓ ALL VALIDATION TESTS PASSED!${NC}"; echo "### ✅ ALL TESTS PASSED - PRODUCTION READY" >> "$REPORT_FILE"; } || { echo -e "${YELLOW}⚠ TESTS PASSED WITH WARNINGS${NC}"; echo "### ⚠️ PASSED WITH WARNINGS" >> "$REPORT_FILE"; }
    FINAL_EXIT=0
else
    echo -e "${RED}✗ VALIDATION TESTS FAILED - Critical issues!${NC}"; echo "### ❌ TESTS FAILED - REQUIRES FIXES" >> "$REPORT_FILE"; FINAL_EXIT=1
fi

echo -e "\nReport saved to: ${YELLOW}$REPORT_FILE${NC}\n"
echo -e "\n---\n*Generated: $TIMESTAMP by AICM Validation Suite*" >> "$REPORT_FILE"
exit $FINAL_EXIT

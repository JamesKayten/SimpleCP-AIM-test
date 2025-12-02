# CLAUDE.md - AIM Workflow Instructions

**This file defines the TCC/OCC workflow for AI collaboration.**

---

## Roles

- **OCC** (Online Claude Code) = Developer
  - Writes code on feature branches (claude/*)
  - Commits and pushes to remote
  - Updates BOARD.md when work is ready for review

- **TCC** (Testing/Coordination Claude) = Project Manager
  - Validates OCC branches before merge
  - Runs tests and checks compliance
  - Merges validated work to main
  - Updates BOARD.md after completing tasks

---

## Workflow

1. **OCC** creates feature branch: `claude/feature-name-<session-id>`
2. **OCC** commits work and pushes to remote
3. **OCC** writes task to BOARD.md under "Tasks FOR TCC"
4. **TCC** validates the branch (tests, compliance)
5. **TCC** merges to main if valid, or posts issues to BOARD.md
6. **TCC** deletes merged branch and updates BOARD.md

---

## Board Location

Task board: `docs/BOARD.md`

---

## Session Start

When starting a session, check `docs/BOARD.md` for:
- Tasks assigned to your role
- Pending branches to process
- Status of recent work

---

## MANDATORY: Pattern Propagation Rule

**BEFORE fixing ANY pattern (paths, APIs, configs, names):**

### 1. COMPREHENSIVE SEARCH (MANDATORY)
```bash
grep -rn "<pattern>" --include="*.sh" --include="*.py" --include="*.swift" --include="*.md" .
```

### 2. SYSTEMATIC FIX (ALL OR NONE)
- List ALL files containing the pattern
- Fix ALL occurrences, never just the one encountered
- Test ALL affected functionality
- Update related documentation

### 3. SOURCE TEMPLATE CHECK (MANDATORY)
- If pattern came from `aim init`, fix the AIM framework source templates
- Prevent future propagation of the issue

### 4. VALIDATION (MANDATORY)
- Search again to confirm ZERO remaining instances
- Use `/fix-pattern` command for systematic approach

### Common Patterns Requiring Full Propagation:
- **Hardcoded paths:** `/home/user`, `/Users/`, `/Volumes/`
- **Project names:** Hardcoded references to specific projects
- **Absolute paths:** Should be relative with dynamic detection
- **API changes:** Endpoint updates, authentication changes
- **Config keys:** Renamed or restructured configuration

### Standard Path Detection (use in ALL shell scripts):
```bash
# Use relative paths - detect repo root from script location
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
```

**RULE: Partial fixes create technical debt. Fix the pattern completely or don't fix it at all.**

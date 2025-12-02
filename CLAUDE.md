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

## Pattern Propagation Rule

When fixing ANY pattern (paths, APIs, configs):
1. `grep -rn "<pattern>" .` to find ALL instances
2. Fix ALL occurrences, not just the one encountered
3. If pattern came from AIM init, fix the SOURCE TEMPLATE

### Common Patterns to Check:
- Hardcoded paths: `/home/user`, `/Users/`, `/Volumes/`
- Project names: `SimpleCP`, `AI-Collaboration-Management`
- Absolute paths that should be relative

### Standard Path Detection (use in ALL shell scripts):
```bash
# Use relative paths - detect repo root from script location
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
```

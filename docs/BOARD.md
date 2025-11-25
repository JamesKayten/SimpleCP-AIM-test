# BOARD - SimpleCP

**Last Updated:** 2025-11-25 15:30 PST

---

## Tasks FOR OCC (TCC writes here, OCC reads)

_None pending_

---

## Tasks FOR TCC (OCC writes here, TCC reads)

### Task: Review and merge folder UI fixes
**Repository:** SimpleCP
**Branch:** `claude/check-the-b-01P6K6CHW47rNqPXd1J1Mt7L`

**Fixes implemented:**
1. **Hardcoded path fix** (`BackendService.swift:498`)
   - Changed `/clipboard_manager` to `/Documents/SimpleCP`

2. **"Rename Folder..." menu implementation** (`ContentView.swift`)
   - Previously was `// TODO: Implement` - did nothing!
   - Now shows submenu to pick which folder to rename
   - Opens rename dialog with pre-filled name

3. **Folder selection state** (`SavedSnippetsColumn.swift`, `ContentView.swift`)
   - Added visual selection indicator (accent color bar + highlight)
   - Clicking folder now selects AND expands/collapses
   - Better UX for folder interactions

**What TCC needs to do:**
- [ ] Review code changes in the 3 modified files
- [ ] Test folder rename from "Manage Folders" menu
- [ ] Test folder click behavior (should select + toggle expansion)
- [ ] Verify hardcoded path is correct
- [ ] If tests pass, merge to main

**Files changed:**
```
frontend/SimpleCP-macOS/Sources/SimpleCP/Services/BackendService.swift
frontend/SimpleCP-macOS/Sources/SimpleCP/Views/ContentView.swift
frontend/SimpleCP-macOS/Sources/SimpleCP/Components/SavedSnippetsColumn.swift
```

**Commit:** `9f6a130`

---

## Roles

- **OCC** = Developer (writes code, commits to feature branches)
- **TCC** = Project Manager (tests, merges to main)

---

**Simple is better.**

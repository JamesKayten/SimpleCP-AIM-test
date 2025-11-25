# ACTIVE ASSIGNMENT - Complete BackendService.swift Rewrite

## Task Overview
**ASSIGNED TO:** OCC
**PRIORITY:** 1 (Critical)
**ESTIMATED EFFORT:** 8 hours

## What to do
Complete rewrite of the BackendService.swift component due to persistent bugs and instability:

1. **Backend Process Lifecycle Issues**
   - Backend processes keep dying unexpectedly
   - Connection reliability problems between frontend and backend
   - Process monitoring and auto-restart mechanisms are unstable

2. **Swift Concurrency Problems**
   - Multiple MainActor isolation issues
   - Timer callback handling problems
   - deinit method concurrency conflicts
   - Ongoing build warnings despite multiple fix attempts

3. **Architecture Issues**
   - Component is overly complex with mixed responsibilities
   - Poor separation between process management and health monitoring
   - Error handling is inconsistent and unreliable

## Which files
**PRIMARY FILE:**
- `/Volumes/User_Smallfavor/Users/Smallfavor/Documents/SimpleCP/frontend/SimpleCP-macOS/Sources/SimpleCP/Services/BackendService.swift`

**RELATED COMPONENTS (may need updates):**
- `ContentView.swift` (connection status UI)
- `ClipboardManager.swift` (if backend API calls need changes)

## Requirements for Rewrite
1. **Clean Swift Concurrency Implementation**
   - Proper @MainActor usage where needed
   - No concurrency warnings
   - Correct async/await patterns

2. **Reliable Process Management**
   - Stable backend process lifecycle
   - Robust auto-restart with exponential backoff
   - Clean shutdown procedures

3. **Better Architecture**
   - Separate concerns: ProcessManager, HealthMonitor, ConnectionManager
   - Clear error handling and recovery strategies
   - Simplified state management

4. **Compliance Standards**
   - File size ≤300 lines (split into multiple files if needed)
   - Full test coverage
   - No security vulnerabilities
   - Follows Swift best practices

## How to verify
1. **Build Tests**
   - Swift build completes with no warnings
   - No concurrency-related build errors

2. **Functional Tests**
   - Backend starts reliably and stays running
   - Frontend connects and maintains stable connection
   - Auto-restart works correctly when backend dies
   - Health checks function properly

3. **Code Quality**
   - All files ≤300 lines
   - Proper separation of concerns
   - Clean, readable, maintainable code
   - Complete documentation

## Current Issues Context
- User reports "whole thing is still buggy as hell"
- Previous piecemeal fixes have not resolved fundamental problems
- System needs complete architectural overhaul for stability

## Acceptance Criteria
- [ ] No Swift build warnings or errors
- [ ] Backend process runs stably without unexpected termination
- [ ] Frontend maintains reliable connection to backend
- [ ] All file size limits met (≤300 lines per file)
- [ ] Full test coverage implemented
- [ ] Code follows project standards and best practices
- [ ] Documentation is complete and accurate

---

**DEADLINE:** ASAP - Critical blocking issue for project functionality
**NEXT REVIEW:** Upon completion by OCC
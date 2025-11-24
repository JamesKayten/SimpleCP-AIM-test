# TCC Enforcement System

**Purpose:** Ensure TCC ALWAYS completes all 3 steps of the workflow
**Problem Solved:** TCC frequently skips Step 3 (local sync), causing stale local files
**Solution:** Multi-layer enforcement with error correction

---

## 🎯 The Problem

### TCC's 3 Mandatory Steps:
1. **Verify files** - Run tests, linters, builds
2. **Merge to main** - Merge OCC's branch and push to GitHub
3. **Update local** - `git pull origin main` ← **THIS GETS SKIPPED**

### Why It Matters:
Without Step 3, the local working directory has stale files. When the user tests locally, they're testing old code. This causes:
- Confusion about what's actually merged
- Wasted time debugging "fixed" issues
- Lack of trust in the collaboration system

---

## 🛡️ Multi-Layer Enforcement

### Layer 1: Enforcement Script (`tcc-enforce.sh`)

**Location:** `.ai-framework/tcc-enforce.sh`

**Features:**
- Atomic execution - all 3 steps complete or none
- State tracking prevents partial completion
- Automatic verification (local commit = remote commit)
- Exits with error if ANY step fails
- Color-coded output for clarity

**Usage:**
```bash
cd /home/user/SimpleCP
./.ai-framework/tcc-enforce.sh [branch-name]
```

**What It Does:**
1. Acquires lock (prevents concurrent runs)
2. Initializes state tracking
3. **Step 1:** Fetches, checks out branch, runs validation
4. **Step 2:** Merges to main, pushes to GitHub
5. **Step 3:** Pulls from main, updates local
6. **Verifies:** Local commit == remote commit
7. Reports success or failure

**Error Handling:**
- Any failure exits immediately
- State file shows what completed
- Clear error messages explain what went wrong

---

### Layer 2: Git Post-Merge Hook

**Location:** `.git/hooks/post-merge`

**Features:**
- Automatically runs after any merge to main
- Checks if local matches remote
- Auto-pulls if behind
- Prevents stale local state

**When It Runs:**
- After `git merge <branch>` on main
- Only on main branch (ignores other branches)

**What It Does:**
1. Fetches latest from origin/main
2. Compares local vs remote commit
3. If different, runs `git pull origin main`
4. Reports synchronization status

**Safety:**
- Only runs on main branch
- Graceful error handling
- Network failure tolerance

---

### Layer 3: Enhanced Slash Command

**Location:** `.claude/commands/works-ready.md`

**Features:**
- Explicit instructions to use enforcement script
- Checkpoint system for manual execution
- Verification protocol
- Structured report format

**Improvements:**
- **Priority 1:** Use enforcement script
- **Priority 2:** Manual with checkpoints
- **Priority 3:** Verification required
- Cannot claim success without verification

**Report Requirements:**
- Must show all 3 steps completed
- Must show commit SHAs (local and remote)
- Must show they match
- Must confirm branch status

---

### Layer 4: State Tracking

**Files:**
- `.ai-framework/.tcc-state` - Current workflow state
- `.tcc-checkpoint` - Manual workflow checkpoints
- `.ai-framework/.tcc-lock` - Prevents concurrent runs

**State File Format:**
```json
{
  "step": 3,
  "branch": "occ-feature-branch",
  "timestamp": "2025-11-24T12:00:00Z",
  "completed": [1, 2, 3]
}
```

**Benefits:**
- Track progress through workflow
- Detect incomplete workflows
- Audit trail for debugging
- Recovery from interruptions

---

## 📊 Enforcement Mechanisms

### Mechanism 1: Atomic Execution

**Concept:** All 3 steps complete or none

**Implementation:**
- Enforcement script uses `set -e` (exit on error)
- Each step validates before proceeding
- Final verification required
- State only marked complete after all 3 steps

**Benefit:** Cannot have partial completion

---

### Mechanism 2: Verification Protocol

**Concept:** Prove local matches remote

**Implementation:**
```bash
# Get both commits
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

# Must match
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "❌ VERIFICATION FAILED"
    exit 1
fi
```

**Benefit:** Cannot fake completion

---

### Mechanism 3: Checkpoint System

**Concept:** Track progress through manual workflow

**Implementation:**
```bash
echo "TCC_STEP=1" > .tcc-checkpoint  # After step 1
echo "TCC_STEP=2" > .tcc-checkpoint  # After step 2
echo "TCC_STEP=3" > .tcc-checkpoint  # After step 3

# Verify before cleanup
if [ "$(cat .tcc-checkpoint)" != "TCC_STEP=3" ]; then
    echo "❌ INCOMPLETE"
    exit 1
fi
```

**Benefit:** Explicit progress markers

---

### Mechanism 4: Post-Merge Hook

**Concept:** Automatic sync after merge

**Implementation:**
- Git hook runs after merge
- Checks local vs remote
- Auto-pulls if needed

**Benefit:** Safety net even if TCC forgets

---

## 🚀 Usage Guide

### Preferred Method: Use Enforcement Script

**When to use:** Always, unless script is broken

**How:**
```bash
# From project root
./.ai-framework/tcc-enforce.sh <occ-branch>

# The script handles everything
```

**Output:**
```
═══════════════════════════════════════════════════════
  🤖 TCC Enforcement Protocol
  3 MANDATORY STEPS: Verify → Merge → Update Local
═══════════════════════════════════════════════════════

ℹ️  Target branch: occ-feature-branch

┌─────────────────────────────────────────────────────┐
│  STEP 1/3: FILE VERIFICATION                        │
└─────────────────────────────────────────────────────┘
...
✅ STEP 1 COMPLETE

┌─────────────────────────────────────────────────────┐
│  STEP 2/3: MERGE TO MAIN                            │
└─────────────────────────────────────────────────────┘
...
✅ STEP 2 COMPLETE

┌─────────────────────────────────────────────────────┐
│  STEP 3/3: UPDATE LOCAL (MANDATORY!)               │
└─────────────────────────────────────────────────────┘
...
✅ STEP 3 COMPLETE

═══════════════════════════════════════════════════════
✅ ALL 3 STEPS COMPLETED SUCCESSFULLY!
═══════════════════════════════════════════════════════
```

---

### Alternative: Manual with Checkpoints

**When to use:** Only if enforcement script fails

**How:**
```bash
# Step 1: Verify
echo "TCC_STEP=0" > .tcc-checkpoint
git fetch origin && git checkout <occ-branch>
# Run tests here
echo "TCC_STEP=1" > .tcc-checkpoint

# Step 2: Merge
git checkout main && git merge <occ-branch> && git push origin main
echo "TCC_STEP=2" > .tcc-checkpoint

# Step 3: Update local (CRITICAL)
git pull origin main
echo "TCC_STEP=3" > .tcc-checkpoint

# Verify completion
[ "$(cat .tcc-checkpoint)" == "TCC_STEP=3" ] && echo "✅ COMPLETE" || echo "❌ INCOMPLETE"
rm .tcc-checkpoint
```

---

### Required Verification

**After any workflow execution:**

```bash
# 1. Check branch
git branch --show-current
# Output must be: main

# 2. Check commits match
git rev-parse HEAD
git rev-parse origin/main
# Both outputs must be identical

# 3. Check status
git status
# Output should include: "Your branch is up to date with 'origin/main'"
```

---

## 📋 TCC Commitment Protocol

As TCC, I commit to:

### 1. Use Enforcement Script First
- Always try the enforcement script
- Only use manual if script fails
- Report why script couldn't be used

### 2. Never Skip Step 3
- Step 3 is MANDATORY
- Cannot claim completion without it
- If impossible, report incomplete workflow

### 3. Always Verify
- Run verification commands
- Report exact commit SHAs
- Confirm they match

### 4. Report Accurately
- Use structured report format
- Show all 3 steps completed
- Include verification results

---

## 🔍 Troubleshooting

### Problem: Enforcement script fails

**Symptoms:**
- Script exits with error
- State file shows incomplete

**Solutions:**
1. Read the error message
2. Fix the underlying issue
3. Re-run the script

**Common Issues:**
- Validation fails → Fix code issues
- Merge conflicts → Resolve conflicts
- Network issues → Check connectivity

---

### Problem: Manual workflow incomplete

**Symptoms:**
- Checkpoint file shows step < 3
- Verification fails
- Local != remote

**Solution:**
```bash
# Check what step you're on
cat .tcc-checkpoint

# Complete remaining steps
# If on step 2, run:
git pull origin main
echo "TCC_STEP=3" > .tcc-checkpoint

# Verify
git rev-parse HEAD
git rev-parse origin/main
```

---

### Problem: Post-merge hook not running

**Symptoms:**
- Merge completes but local not synced
- Hook doesn't output anything

**Solutions:**
1. Check hook is executable:
   ```bash
   chmod +x .git/hooks/post-merge
   ```

2. Verify hook file exists:
   ```bash
   ls -la .git/hooks/post-merge
   ```

3. Test hook manually:
   ```bash
   .git/hooks/post-merge
   ```

---

### Problem: State file corruption

**Symptoms:**
- Script won't start
- State shows invalid JSON

**Solution:**
```bash
# Remove corrupted state
rm .ai-framework/.tcc-state
rm .ai-framework/.tcc-lock

# Re-run workflow
./.ai-framework/tcc-enforce.sh <branch>
```

---

## 🎓 Understanding the Design

### Why Multi-Layer?

**Defense in Depth:** Multiple independent mechanisms

- If TCC forgets, script catches it
- If script isn't used, checkpoints catch it
- If checkpoints are skipped, verification catches it
- If everything else fails, git hook catches it

**Redundancy:** Safety through overlap

Each layer compensates for the others' weaknesses:
- Script can fail due to bugs
- Manual can be done wrong
- Verification can be skipped
- Hook runs automatically

**Error Correction:** Self-healing

The system actively corrects the problem:
- Script forces correct execution
- Hook auto-pulls if needed
- Verification shows the issue
- Clear remediation steps

---

### Why This Approach Works

**Behavioral Change:**
- Explicit instructions to use script
- Script is easier than manual
- Clear success/failure feedback

**Technical Enforcement:**
- Atomic operations prevent partial completion
- State tracking enables auditing
- Verification proves compliance

**Cultural Shift:**
- Step 3 is now first-class requirement
- Cannot be "forgotten"
- System enforces the rule, not humans

---

## 📈 Success Metrics

### Measurement:
Track how often local matches remote after TCC workflow:
```bash
# After each TCC run
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
[ "$LOCAL" == "$REMOTE" ] && echo "✅" || echo "❌"
```

### Target:
- **Before enforcement:** ~50% success rate
- **After enforcement:** 100% success rate

### Benefits:
- User always has latest code locally
- No confusion about what's merged
- Testing is reliable
- Trust in the system increases

---

## 🔮 Future Enhancements

### Possible Additions:

1. **Monitoring Dashboard**
   - Track success rate over time
   - Identify failure patterns
   - Alert on repeated failures

2. **Remote Verification Service**
   - Independent check that local = remote
   - Cannot be bypassed by TCC
   - Reports to user directly

3. **Automated Recovery**
   - If incomplete workflow detected
   - Auto-complete remaining steps
   - Notify user of auto-fix

4. **LLM Memory Enhancement**
   - Store "Step 3 is critical" in system prompt
   - Reinforce through examples
   - Pattern matching for skipped steps

---

## 📖 Reference

### Key Files:
- `.ai-framework/tcc-enforce.sh` - Enforcement script
- `.git/hooks/post-merge` - Git hook
- `.claude/commands/works-ready.md` - Slash command
- `.ai-framework/TCC_ENFORCEMENT_SYSTEM.md` - This document

### Quick Commands:
```bash
# Use enforcement script
./.ai-framework/tcc-enforce.sh <branch>

# Verify local = remote
git rev-parse HEAD && git rev-parse origin/main

# Check current state
cat .ai-framework/.tcc-state

# Sync manually if needed
git pull origin main
```

---

## ✅ Summary

**The Problem:** TCC skips Step 3 (local sync)

**The Solution:** Multi-layer enforcement system

**The Result:** Local ALWAYS matches GitHub after merge

**The Mechanism:**
1. Enforcement script (preferred)
2. Git post-merge hook (automatic)
3. Enhanced slash command (instructions)
4. State tracking (audit trail)

**The Commitment:** TCC will use these tools and never skip Step 3

---

**Last Updated:** 2025-11-24
**Version:** 1.0 - Initial Enforcement System
**Status:** Active and enforced

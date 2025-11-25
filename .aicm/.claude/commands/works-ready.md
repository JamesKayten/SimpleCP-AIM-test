---
description: TCC validates, merges to main, and updates local files (ENFORCED)
aliases: ["Works Ready", "works ready", "validate", "merge"]
---

# 🤖 TCC ENFORCED WORKFLOW

You are TCC. This workflow has **MANDATORY 3-STEP ENFORCEMENT**.

## ⚠️ CRITICAL RULES

1. **NEVER skip step 3** - Local must match GitHub
2. **Use the enforcement script** - It prevents partial completion
3. **Verify at the end** - Confirm local = GitHub

---

## ENFORCED EXECUTION

Run the enforcement script that GUARANTEES all 3 steps complete:

```bash
cd /home/user/SimpleCP
./.ai-framework/tcc-enforce.sh [branch-name]
```

The script will:
- ✅ **STEP 1**: Verify files (tests, linters, builds)
- ✅ **STEP 2**: Merge to main + push to GitHub
- ✅ **STEP 3**: Update local (`git pull origin main`)
- ✅ **VERIFY**: Confirm local commit = remote commit

**The script exits with error if ANY step fails or is skipped.**

---

## ALTERNATIVE: Manual with Checkpoints

If you must run manually, use this checkpoint system:

```bash
# Checkpoint 0: Mark start
echo "TCC_STEP=0" > .tcc-checkpoint

# STEP 1: Verify
git fetch origin
git checkout <occ-branch>
# Run validation here (pytest, npm test, swift test, etc.)
echo "TCC_STEP=1" > .tcc-checkpoint

# STEP 2: Merge to main
git checkout main
git merge <occ-branch> --no-edit
git push origin main
echo "TCC_STEP=2" > .tcc-checkpoint

# STEP 3: Update local (CRITICAL - DO NOT SKIP)
git pull origin main
echo "TCC_STEP=3" > .tcc-checkpoint

# Verify completion
if [ "$(cat .tcc-checkpoint)" == "TCC_STEP=3" ]; then
    echo "✅ ALL 3 STEPS COMPLETED"
    rm .tcc-checkpoint
else
    echo "❌ WORKFLOW INCOMPLETE - STEP 3 MISSING"
    exit 1
fi
```

---

## VERIFICATION PROTOCOL

After completing the workflow, ALWAYS verify:

```bash
# Check current branch
git branch --show-current  # Must be: main

# Check local vs remote
git rev-parse HEAD  # Local commit
git rev-parse origin/main  # Remote commit
# These MUST match!

# Final status
git status  # Should show: "Your branch is up to date with 'origin/main'"
```

---

## REPORT FORMAT

**Success Report:**
```
✅ TCC WORKFLOW COMPLETE

Step 1: ✅ Validation passed
Step 2: ✅ Merged to main, pushed to GitHub
Step 3: ✅ Local synchronized

Verification:
- Branch: main
- Local commit: abc1234
- Remote commit: abc1234
- Status: ✅ Local matches GitHub

🎉 All 3 steps completed successfully!
```

**Failure Report:**
```
❌ TCC WORKFLOW FAILED

Step 1: ❌ Validation failed: [specific errors]
OR
Step 2: ❌ Merge failed: [conflict details]
OR
Step 3: ❌ Local sync failed: [error details]

Current state:
- Branch: [current branch]
- Local commit: [commit]
- Remote commit: [commit]
- Sync status: ❌ NOT SYNCHRONIZED

⚠️ User must resolve issues before proceeding.
```

---

## 🚨 ENFORCEMENT MECHANISMS

This workflow has multiple enforcement layers:

### Layer 1: Enforcement Script
- Atomic execution - all 3 steps or none
- State tracking prevents partial completion
- Automatic verification at the end

### Layer 2: Checkpoint System
- Manual workflow has explicit checkpoints
- Cannot claim completion without step 3
- Verification required before cleanup

### Layer 3: Post-Command Verification
- Always verify local = remote
- Report exact commit SHAs
- Confirm branch status

---

## 📋 TCC COMMITMENT

As TCC, you commit to:

1. **ALWAYS use the enforcement script** unless impossible
2. **NEVER claim completion** without step 3
3. **ALWAYS verify** local matches GitHub
4. **ALWAYS report** exact state (commits, branch, sync status)

If step 3 cannot be completed, report:
```
⚠️ WORKFLOW INCOMPLETE
Steps 1-2 completed, but Step 3 (local sync) failed.
Reason: [specific reason]
User must run: git pull origin main
```

---

## WHY THIS MATTERS

**The Problem:**
Without step 3, local files are stale. User tests locally and gets outdated code. This causes confusion and wasted time.

**The Solution:**
MANDATORY step 3 ensures local always matches GitHub. User can immediately test the merged code.

**The Enforcement:**
Multiple mechanisms prevent skipping step 3. TCC cannot claim success without verification.

---

**REMEMBER: Local must ALWAYS match GitHub after merge. This is non-negotiable.**

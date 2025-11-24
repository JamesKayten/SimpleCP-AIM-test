# TCC Enforcement - Quick Start

**One command that guarantees all 3 steps complete.**

---

## 🚀 Quick Start

When TCC needs to validate, merge, and sync:

```bash
cd /home/user/SimpleCP
./.ai-framework/tcc-enforce.sh <occ-branch-name>
```

**That's it!** The script handles everything and **guarantees** Step 3 (local sync) completes.

---

## ✅ What It Does

1. **Verifies** files (tests, linters, builds)
2. **Merges** to main and pushes to GitHub
3. **Updates** local repository (`git pull origin main`)
4. **Verifies** local commit matches remote commit

If ANY step fails, the script exits with error and explains what went wrong.

---

## 📊 Success Output

```
═══════════════════════════════════════════════════════
  🤖 TCC Enforcement Protocol
  3 MANDATORY STEPS: Verify → Merge → Update Local
═══════════════════════════════════════════════════════

ℹ️  Target branch: occ-feature-branch

┌─────────────────────────────────────────────────────┐
│  STEP 1/3: FILE VERIFICATION                        │
└─────────────────────────────────────────────────────┘
✅ STEP 1 COMPLETE: Validation passed

┌─────────────────────────────────────────────────────┐
│  STEP 2/3: MERGE TO MAIN                            │
└─────────────────────────────────────────────────────┘
✅ STEP 2 COMPLETE: Merged to main and pushed

┌─────────────────────────────────────────────────────┐
│  STEP 3/3: UPDATE LOCAL (MANDATORY!)               │
└─────────────────────────────────────────────────────┘
✅ VERIFIED: Local matches GitHub
✅ STEP 3 COMPLETE: Local repository synchronized

═══════════════════════════════════════════════════════
✅ ALL 3 STEPS COMPLETED SUCCESSFULLY!

  ✅ Step 1: Files verified
  ✅ Step 2: Merged to main
  ✅ Step 3: Local updated

  📍 Current branch: main
  📍 Current commit: abc1234
  📍 Status: Local repository synchronized with GitHub
═══════════════════════════════════════════════════════
```

---

## ⚠️ If Script Can't Run

Use manual workflow with checkpoints:

```bash
# Mark start
echo "TCC_STEP=0" > .tcc-checkpoint

# Step 1: Verify
git fetch origin && git checkout <occ-branch>
# Run tests...
echo "TCC_STEP=1" > .tcc-checkpoint

# Step 2: Merge to main
git checkout main && git merge <occ-branch> && git push origin main
echo "TCC_STEP=2" > .tcc-checkpoint

# Step 3: Update local (MANDATORY!)
git pull origin main
echo "TCC_STEP=3" > .tcc-checkpoint

# Verify completion
if [ "$(cat .tcc-checkpoint)" == "TCC_STEP=3" ]; then
    echo "✅ ALL 3 STEPS COMPLETED"
    rm .tcc-checkpoint
else
    echo "❌ INCOMPLETE - Step 3 missing!"
    exit 1
fi
```

---

## 🔍 Verify Success

After workflow completes, verify:

```bash
# Both must show the same commit
git rev-parse HEAD           # Local commit
git rev-parse origin/main    # Remote commit

# Should say "up to date with origin/main"
git status
```

---

## 📋 TCC Rules

1. **Use the enforcement script** (`.ai-framework/tcc-enforce.sh`)
2. **Never skip Step 3** (local sync)
3. **Always verify** (local = remote)
4. **Report accurately** (show all 3 steps completed)

---

## 🆘 Troubleshooting

### Script fails with error
→ Read the error message and fix the underlying issue

### Local doesn't match remote
→ Run: `git pull origin main`

### Script won't start
→ Check: `chmod +x .ai-framework/tcc-enforce.sh`

---

## 📚 Full Documentation

See: `.ai-framework/TCC_ENFORCEMENT_SYSTEM.md`

---

**Remember: All 3 steps must complete. The script guarantees it.**

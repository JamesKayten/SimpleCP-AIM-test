# AICM ↔ SimpleCP Bidirectional Sync

**Problem:** While developing SimpleCP, we discover flaws in AICM that need fixing. This causes confusion about which repo to update.

**Solution:** Bidirectional sync allows fixing issues in either repo and syncing improvements back and forth.

---

## 🎯 Repository Roles

### AICM (Master Framework)
**Location:** `/home/user/AICM` or `https://github.com/JamesKayten/AI-Collaboration-Management`

**Purpose:**
- Master source of truth for the AI Collaboration framework
- Reusable framework to give away when proven
- Contains `.ai-framework` template

### SimpleCP (Project Using Framework)
**Location:** `/home/user/SimpleCP` or `https://github.com/JamesKayten/SimpleCP`

**Purpose:**
- Actual project using AICM framework
- Dogfooding environment (test AICM in real use)
- Source of framework improvements discovered during use

---

## 🔄 Sync Direction Decision Tree

### When to Sync FROM SimpleCP TO AICM

**Scenarios:**
- ✅ Fixed an AICM bug while working on SimpleCP
- ✅ Improved framework scripts/tools
- ✅ Enhanced TCC enforcement system
- ✅ Better documentation for framework features
- ✅ New slash commands that apply to all projects

**Command:**
```bash
cd /home/user/SimpleCP
./sync-to-aicm.sh
```

**What it does:**
1. Checks for uncommitted changes in SimpleCP
2. Shows diff between frameworks
3. Asks for confirmation
4. Syncs `.ai-framework/` from SimpleCP → AICM
5. Syncs related files (slash commands, guides)
6. Shows AICM git status

**Then:**
```bash
cd /home/user/AICM
git diff  # Review changes
git add -A
git commit -m "🔧 Framework improvements from SimpleCP"
git push
```

---

### When to Sync FROM AICM TO SimpleCP

**Scenarios:**
- ✅ Updated framework in AICM master repo
- ✅ Fixed AICM issues directly in AICM repo
- ✅ Want latest framework features in SimpleCP
- ✅ Starting a new work session on SimpleCP
- ✅ Another contributor improved AICM

**Command:**
```bash
cd /home/user/SimpleCP
./sync-from-aicm.sh
```

**What it does:**
1. Updates AICM from GitHub (`git pull`)
2. Checks for uncommitted changes in SimpleCP
3. Shows diff between frameworks
4. Asks for confirmation
5. Syncs `.ai-framework/` from AICM → SimpleCP
6. Syncs related files
7. Shows SimpleCP git status

**Then:**
```bash
cd /home/user/SimpleCP
git diff  # Review changes
git add -A
git commit -m "📦 Sync framework from AICM"
```

---

## 📋 Complete Workflows

### Workflow 1: Fix AICM Bug in SimpleCP Context

**Situation:** While working on SimpleCP, you discover TCC enforcement script has a bug.

**Steps:**
1. **Fix in SimpleCP:**
   ```bash
   cd /home/user/SimpleCP
   # Edit .ai-framework/tcc-enforce.sh
   # Test the fix
   git add .ai-framework/
   git commit -m "🐛 Fix TCC enforcement bug"
   ```

2. **Sync to AICM:**
   ```bash
   ./sync-to-aicm.sh
   # Review changes, confirm sync
   ```

3. **Commit in AICM:**
   ```bash
   cd /home/user/AICM
   git add -A
   git commit -m "🐛 Fix TCC enforcement bug (from SimpleCP)"
   git push
   ```

4. **Continue SimpleCP work:**
   ```bash
   cd /home/user/SimpleCP
   # Continue with your SimpleCP features
   ```

---

### Workflow 2: Improve AICM Directly

**Situation:** You want to improve AICM documentation or add a new framework feature.

**Steps:**
1. **Clone/Update AICM:**
   ```bash
   cd /home/user/AICM
   git pull origin main
   ```

2. **Make changes:**
   ```bash
   # Edit .ai-framework/ files
   # Test changes
   git add -A
   git commit -m "✨ Add new framework feature"
   git push
   ```

3. **Sync to SimpleCP:**
   ```bash
   cd /home/user/SimpleCP
   ./sync-from-aicm.sh
   # Review changes, confirm sync
   ```

4. **Commit in SimpleCP:**
   ```bash
   git add -A
   git commit -m "📦 Sync framework updates from AICM"
   ```

---

### Workflow 3: Start New SimpleCP Session

**Situation:** Starting a new work session on SimpleCP, want latest framework.

**Steps:**
1. **Sync from AICM:**
   ```bash
   cd /home/user/SimpleCP
   ./sync-from-aicm.sh
   ```

2. **If changes pulled:**
   ```bash
   git add -A
   git commit -m "📦 Update framework to latest"
   ```

3. **Start work:**
   ```bash
   # Now you have latest framework
   # Continue with SimpleCP development
   ```

---

## 🛡️ Safety Features

### Both Sync Scripts Include:

1. **Uncommitted Changes Check**
   - Won't sync if you have uncommitted changes
   - Prompts you to commit first
   - Prevents accidental loss of work

2. **Diff Preview**
   - Shows what files will change
   - Shows what's different
   - Allows you to cancel

3. **Confirmation Prompt**
   - Must explicitly confirm sync
   - Prevents accidental syncs
   - Gives you time to review

4. **Exclusions**
   - `.tcc-state` (ephemeral state files)
   - `.tcc-lock` (lock files)
   - `*.tmp` (temporary files)
   - Only syncs framework, not project files

5. **Post-Sync Status**
   - Shows git status after sync
   - Reminds you to review and commit
   - Clear next steps

---

## 📁 What Gets Synced

### Always Synced:
- ✅ `.ai-framework/` directory (all framework files)
- ✅ `.claude/commands/works-ready.md` (TCC command)
- ✅ `.git/hooks/post-merge` (git hook)
- ✅ `TCC_WORKFLOW_GUIDE.md` (workflow docs)

### Never Synced:
- ❌ Project source code (`src/`, `frontend/`, `backend/`)
- ❌ Project-specific files (`README.md`, `package.json`)
- ❌ Temporary files (`.tcc-state`, `.tcc-lock`)
- ❌ Build artifacts (`dist/`, `build/`, `__pycache__/`)

---

## 🚨 Conflict Resolution

### If Sync Shows Many Differences:

**Option 1: Review Carefully**
```bash
# Before syncing, review what's different
diff -r /home/user/AICM/.ai-framework/ /home/user/SimpleCP/.ai-framework/
```

**Option 2: Sync Selectively**
```bash
# Sync just one file
cp /home/user/AICM/.ai-framework/tcc-enforce.sh /home/user/SimpleCP/.ai-framework/
```

**Option 3: Manual Merge**
```bash
# Use a merge tool
meld /home/user/AICM/.ai-framework/ /home/user/SimpleCP/.ai-framework/
```

---

### If You're Unsure Which Direction to Sync:

**Question:** "Which version is better?"

**Check:**
1. **When were they last modified?**
   ```bash
   ls -lt /home/user/AICM/.ai-framework/
   ls -lt /home/user/SimpleCP/.ai-framework/
   ```

2. **What are the differences?**
   ```bash
   diff -r /home/user/AICM/.ai-framework/ /home/user/SimpleCP/.ai-framework/
   ```

3. **Which has the fix you need?**
   - If SimpleCP has the fix → Sync TO AICM
   - If AICM has the fix → Sync FROM AICM

**Rule of Thumb:**
- Working on SimpleCP and found a bug? → Fix in SimpleCP, sync to AICM
- Working on AICM itself? → Fix in AICM, sync to SimpleCP

---

## 🎓 Best Practices

### 1. Commit Before Syncing
Always commit your current work before syncing:
```bash
git add -A
git commit -m "WIP: current progress"
# Now safe to sync
```

### 2. Sync Frequently
Don't let the frameworks drift too far apart:
- Sync after fixing any AICM bug
- Sync at start of each session
- Sync before major framework changes

### 3. Test After Syncing
After syncing, verify everything still works:
```bash
# In SimpleCP
./sync-from-aicm.sh
# Test TCC enforcement
./.ai-framework/tcc-enforce.sh --help
```

### 4. Document Why You Synced
Use clear commit messages:
```bash
# Good
git commit -m "🐛 Fix TCC step 3 enforcement bug (synced to AICM)"

# Bad
git commit -m "sync stuff"
```

### 5. Keep AICM Clean
AICM is the master framework, keep it generic:
- No SimpleCP-specific code
- No hardcoded paths to SimpleCP
- Keep it reusable

---

## 🔍 Troubleshooting

### Problem: sync-to-aicm.sh says "AICM directory not found"

**Solution:**
```bash
cd /home/user
git clone https://github.com/JamesKayten/AI-Collaboration-Management.git AICM
```

---

### Problem: Sync shows many differences, unsure what to do

**Solution:**
```bash
# Review the differences
diff -r /home/user/AICM/.ai-framework/ /home/user/SimpleCP/.ai-framework/ | less

# Or sync manually for specific files
cp /home/user/AICM/.ai-framework/FILE /home/user/SimpleCP/.ai-framework/
```

---

### Problem: Accidentally synced wrong direction

**Solution:**
```bash
# Revert the sync
cd /home/user/SimpleCP  # or AICM
git checkout HEAD -- .ai-framework/
git status  # Verify reverted

# Sync in correct direction
./sync-from-aicm.sh  # or sync-to-aicm.sh
```

---

### Problem: Sync creates merge conflicts

**Solution:**
The sync scripts don't merge, they overwrite. If you have divergent changes:
1. Manually review both versions
2. Pick the better one
3. Copy good parts from the other
4. Sync the merged version

---

## 📊 Sync Decision Matrix

| Situation | Action | Command | Result |
|-----------|--------|---------|--------|
| Fixed AICM bug in SimpleCP | Sync to AICM | `./sync-to-aicm.sh` | AICM gets the fix |
| Improved AICM directly | Sync to SimpleCP | `./sync-from-aicm.sh` | SimpleCP gets improvement |
| Starting SimpleCP session | Sync from AICM | `./sync-from-aicm.sh` | SimpleCP gets latest |
| Starting AICM work | Sync from SimpleCP | (in AICM) `./sync-from-simplecp.sh` | AICM gets SimpleCP fixes |
| Enhanced TCC enforcement | Sync to AICM | `./sync-to-aicm.sh` | AICM gets enhancement |
| Unsure | Check diffs | `diff -r AICM/.ai-framework SimpleCP/.ai-framework` | See differences |

---

## 🚀 Quick Reference

### In SimpleCP:

**Push improvements to AICM:**
```bash
./sync-to-aicm.sh
cd /home/user/AICM && git add -A && git commit -m "Framework update" && git push
```

**Pull updates from AICM:**
```bash
./sync-from-aicm.sh
git add -A && git commit -m "Sync framework from AICM"
```

---

### In AICM:

**Pull improvements from SimpleCP:**
```bash
./sync-from-simplecp.sh
git add -A && git commit -m "Framework update from SimpleCP" && git push
```

**Push updates to SimpleCP:**
```bash
./sync-to-simplecp.sh
# Then go to SimpleCP and commit
```

---

## 🎯 Remember

1. **AICM is the master** - it's the framework to give away
2. **SimpleCP is the testbed** - where you discover issues
3. **Sync bidirectionally** - improvements flow both ways
4. **Commit before syncing** - always
5. **Test after syncing** - always

---

**The sync scripts make it easy to keep both repos in sync, preventing confusion and ensuring improvements benefit both projects.**

**Last Updated:** 2025-11-24
**Status:** Active bidirectional sync established

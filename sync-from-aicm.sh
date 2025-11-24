#!/bin/bash
# sync-from-aicm.sh
# Sync .ai-framework updates from AICM master repository to SimpleCP

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SIMPLECP_DIR="/home/user/SimpleCP"
AICM_DIR="/home/user/AICM"
FRAMEWORK_DIR=".ai-framework"

echo ""
echo "════════════════════════════════════════════════════════"
echo "  📥 SYNC FROM AICM"
echo "  Pulling framework updates from AICM to SimpleCP"
echo "════════════════════════════════════════════════════════"
echo ""

# Verify directories exist
if [ ! -d "$SIMPLECP_DIR" ]; then
    echo -e "${RED}❌ SimpleCP directory not found: $SIMPLECP_DIR${NC}"
    exit 1
fi

if [ ! -d "$AICM_DIR" ]; then
    echo -e "${RED}❌ AICM directory not found: $AICM_DIR${NC}"
    echo -e "${YELLOW}Run: cd /home/user && git clone https://github.com/JamesKayten/AI-Collaboration-Management.git AICM${NC}"
    exit 1
fi

# Update AICM from GitHub
echo -e "${BLUE}ℹ️  Updating AICM from GitHub...${NC}"
cd "$AICM_DIR"
git fetch origin
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo -e "${YELLOW}⚠️  AICM is behind GitHub. Pulling latest...${NC}"
    git pull origin main
    echo -e "${GREEN}✅ AICM updated${NC}"
else
    echo -e "${GREEN}✅ AICM is up to date${NC}"
fi
echo ""

# Check for uncommitted changes in SimpleCP
cd "$SIMPLECP_DIR"
if [ -n "$(git status --porcelain $FRAMEWORK_DIR)" ]; then
    echo -e "${YELLOW}⚠️  SimpleCP has uncommitted changes in $FRAMEWORK_DIR${NC}"
    echo ""
    git status --short $FRAMEWORK_DIR
    echo ""
    read -p "Commit these changes first? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add $FRAMEWORK_DIR
        git commit -m "🔧 Local framework changes (before sync from AICM)"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${RED}❌ Please commit or stash changes before syncing${NC}"
        exit 1
    fi
fi

# Show what will be synced
echo -e "${BLUE}ℹ️  Analyzing differences...${NC}"
echo ""

# Compare directories
if diff -r "$AICM_DIR/$FRAMEWORK_DIR" "$SIMPLECP_DIR/$FRAMEWORK_DIR" --brief &>/dev/null; then
    echo -e "${GREEN}✅ Frameworks are already in sync!${NC}"
    exit 0
fi

echo "Files that will be synced:"
diff -r "$AICM_DIR/$FRAMEWORK_DIR" "$SIMPLECP_DIR/$FRAMEWORK_DIR" --brief | sed 's|/home/user/||g'
echo ""

# Ask for confirmation
read -p "Proceed with sync? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⚠️  Sync cancelled${NC}"
    exit 0
fi

# Perform sync
echo ""
echo -e "${BLUE}📥 Syncing framework files...${NC}"

# Sync .ai-framework directory
rsync -av --delete \
    --exclude='.tcc-state' \
    --exclude='.tcc-lock' \
    --exclude='*.tmp' \
    "$AICM_DIR/$FRAMEWORK_DIR/" \
    "$SIMPLECP_DIR/$FRAMEWORK_DIR/"

# Sync .claude/commands/works-ready.md
if [ -f "$AICM_DIR/.claude/commands/works-ready.md" ]; then
    mkdir -p "$SIMPLECP_DIR/.claude/commands"
    cp "$AICM_DIR/.claude/commands/works-ready.md" "$SIMPLECP_DIR/.claude/commands/"
    echo -e "${GREEN}✅ Synced works-ready.md${NC}"
fi

# Sync git hook
if [ -f "$AICM_DIR/.git/hooks/post-merge" ]; then
    mkdir -p "$SIMPLECP_DIR/.git/hooks"
    cp "$AICM_DIR/.git/hooks/post-merge" "$SIMPLECP_DIR/.git/hooks/"
    chmod +x "$SIMPLECP_DIR/.git/hooks/post-merge"
    echo -e "${GREEN}✅ Synced post-merge hook${NC}"
fi

# Sync TCC_WORKFLOW_GUIDE.md if it exists
if [ -f "$AICM_DIR/TCC_WORKFLOW_GUIDE.md" ]; then
    cp "$AICM_DIR/TCC_WORKFLOW_GUIDE.md" "$SIMPLECP_DIR/"
    echo -e "${GREEN}✅ Synced TCC_WORKFLOW_GUIDE.md${NC}"
fi

echo ""
echo -e "${GREEN}✅ Sync complete!${NC}"
echo ""

# Show status in SimpleCP
cd "$SIMPLECP_DIR"
echo -e "${BLUE}ℹ️  SimpleCP repository status:${NC}"
git status --short

echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test that everything works"
echo "  3. Commit changes: git add -A && git commit -m 'Sync framework from AICM'"
echo ""

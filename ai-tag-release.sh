#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== AI-Powered SimpleCP Release Tagger ===${NC}\n"

call_ollama() {
    local prompt="$1"
    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        return 1
    fi
    
    RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2\",\"prompt\":\"$prompt\",\"stream\":false}")
    echo "$RESPONSE" | jq -r '.response' 2>/dev/null
}

CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.2.0")
echo -e "Current version: ${GREEN}${CURRENT_VERSION}${NC}"

if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    UNCOMMITTED_FILES=$(git diff --name-only | head -5 | tr '\n' ', ')
    
    echo -e "${BLUE}🤖 Generating commit message...${NC}"
    AI_COMMIT_MSG=$(call_ollama "Generate a single-line git commit message (max 72 chars) for changes to: $UNCOMMITTED_FILES. Reply with only the message.")
    
    if [ ! -z "$AI_COMMIT_MSG" ]; then
        AI_COMMIT_MSG=$(echo "$AI_COMMIT_MSG" | head -1 | sed 's/^["'"'"']//;s/["'"'"']$//')
        echo -e "${GREEN}AI commit message:${NC} ${YELLOW}${AI_COMMIT_MSG}${NC}\n"
        read -p "Use this? (y/n) [y]: " USE_IT
        USE_IT=${USE_IT:-y}
        if [[ $USE_IT == "y" ]]; then
            git add -A
            git commit -m "$AI_COMMIT_MSG"
        fi
    fi
fi

CURRENT_VERSION_NO_V=${CURRENT_VERSION#v}
MAJOR=$(echo $CURRENT_VERSION_NO_V | cut -d. -f1)
MINOR=$(echo $CURRENT_VERSION_NO_V | cut -d. -f2)
NEW_VERSION="v${MAJOR}.$((MINOR + 1)).0"

DIFF=$(git log ${CURRENT_VERSION}..HEAD --pretty=format:"%s" --no-merges | head -5 | tr '\n' ' ')

if [ -z "$DIFF" ]; then
    echo "No changes since last tag"
    exit 1
fi

echo -e "\n${BLUE}New version: ${GREEN}${NEW_VERSION}${NC}"
echo -e "${BLUE}🤖 Generating release notes...${NC}\n"

AI_NOTES=$(call_ollama "For a macOS clipboard manager, analyze these commits: $DIFF. Generate: 1) A 4-word release title, 2) 3 bullet points of user-facing changes. Format: TITLE: [title] NOTES: - [point1] - [point2] - [point3]")

RELEASE_TITLE=$(echo "$AI_NOTES" | grep "TITLE:" | sed 's/TITLE: //' | head -1)
RELEASE_NOTES=$(echo "$AI_NOTES" | sed -n '/NOTES:/,$p' | tail -n +2)

if [ -z "$RELEASE_TITLE" ]; then
    RELEASE_TITLE=$(echo "$AI_NOTES" | head -1)
    RELEASE_NOTES="- $AI_NOTES"
fi

echo -e "${GREEN}Title:${NC} ${YELLOW}${RELEASE_TITLE}${NC}"
echo -e "${GREEN}Notes:${NC}\n${RELEASE_NOTES}\n"

read -p "Proceed? (y/n) [y]: " CONFIRM
CONFIRM=${CONFIRM:-y}

if [[ $CONFIRM == "y" ]]; then
    git tag -a $NEW_VERSION -m "Feature Release ${NEW_VERSION} - ${RELEASE_TITLE}

${RELEASE_NOTES}"
    git push origin main --tags
    echo -e "\n${GREEN}✅ Released ${NEW_VERSION}${NC}"
fi

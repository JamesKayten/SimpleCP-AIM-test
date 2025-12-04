#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== AI-Powered SimpleCP Release Tagger ===${NC}\n"

# Function to call Ollama (local, free)
call_ollama() {
    local prompt="$1"
    
    # Check if Ollama is running
    if ! curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
        return 1
    fi
    
    echo -e "${BLUE}🤖 Using Ollama (local)...${NC}" >&2
    
    RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{
        \"model\": \"llama3.2\",
        \"prompt\": \"$prompt\",
        \"stream\": false
    }")
    
    echo "$RESPONSE" | jq -r '.response' 2>/dev/null
}

# Function to call Groq (free tier)
call_groq() {
    local prompt="$1"
    
    if [ -z "$GROQ_API_KEY" ]; then
        return 1
    fi
    
    echo -e "${BLUE}🤖 Using Groq (free)...${NC}" >&2
    
    RESPONSE=$(curl -s https://api.groq.com/openai/v1/chat/completions \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"llama-3.3-70b-versatile\",
            \"messages\": [{
                \"role\": \"user\",
                \"content\": $(echo "$prompt" | jq -Rs .)
            }],
            \"max_tokens\": 500
        }")
    
    echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null
}

# Function to call Hugging Face (free)
call_huggingface() {
    local prompt="$1"
    
    if [ -z "$HUGGINGFACE_API_KEY" ]; then
        return 1
    fi
    
    echo -e "${BLUE}🤖 Using Hugging Face (free)...${NC}" >&2
    
    RESPONSE=$(curl -s https://api-inference.huggingface.co/models/meta-llama/Llama-3.2-3B-Instruct \
        -H "Authorization: Bearer $HUGGINGFACE_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"inputs\": $(echo "$prompt" | jq -Rs .),
            \"parameters\": {
                \"max_new_tokens\": 500,
                \"return_full_text\": false
            }
        }")
    
    echo "$RESPONSE" | jq -r '.[0].generated_text' 2>/dev/null
}

# Function to call OpenRouter (free tier)
call_openrouter() {
    local prompt="$1"
    
    if [ -z "$OPENROUTER_API_KEY" ]; then
        return 1
    fi
    
    echo -e "${BLUE}🤖 Using OpenRouter (free)...${NC}" >&2
    
    RESPONSE=$(curl -s https://openrouter.ai/api/v1/chat/completions \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"meta-llama/llama-3.2-3b-instruct:free\",
            \"messages\": [{
                \"role\": \"user\",
                \"content\": $(echo "$prompt" | jq -Rs .)
            }]
        }")
    
    echo "$RESPONSE" | jq -r '.choices[0].message.content' 2>/dev/null
}

# Function to try AI services in order
call_ai() {
    local prompt="$1"
    local response=""
    
    # Try Ollama first (completely free, local)
    response=$(call_ollama "$prompt")
    if [ ! -z "$response" ] && [ "$response" != "null" ]; then
        echo "$response"
        return 0
    fi
    
    # Try Groq (generous free tier)
    response=$(call_groq "$prompt")
    if [ ! -z "$response" ] && [ "$response" != "null" ]; then
        echo "$response"
        return 0
    fi
    
    # Try OpenRouter (free models available)
    response=$(call_openrouter "$prompt")
    if [ ! -z "$response" ] && [ "$response" != "null" ]; then
        echo "$response"
        return 0
    fi
    
    # Try Hugging Face (free)
    response=$(call_huggingface "$prompt")
    if [ ! -z "$response" ] && [ "$response" != "null" ]; then
        echo "$response"
        return 0
    fi
    
    return 1
}

# Check for dependencies
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq is required. Install with: brew install jq${NC}"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.2.0")
echo -e "Current version: ${GREEN}${CURRENT_VERSION}${NC}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes${NC}"
    read -p "Commit all changes first? (y/n): " COMMIT_NOW
    
    if [[ $COMMIT_NOW == "y" ]]; then
        git add -A
        read -p "Commit message: " COMMIT_MSG
        git commit -m "$COMMIT_MSG"
    fi
fi

# Calculate next versions
CURRENT_VERSION_NO_V=${CURRENT_VERSION#v}
MAJOR=$(echo $CURRENT_VERSION_NO_V | cut -d. -f1)
MINOR=$(echo $CURRENT_VERSION_NO_V | cut -d. -f2)
PATCH=$(echo $CURRENT_VERSION_NO_V | cut -d. -f3)

NEXT_MAJOR="v$((MAJOR + 1)).0.0"
NEXT_MINOR="v${MAJOR}.$((MINOR + 1)).0"
NEXT_PATCH="v${MAJOR}.${MINOR}.$((PATCH + 1))"

echo -e "\nSelect version bump:"
echo "1) Major: ${GREEN}${NEXT_MAJOR}${NC} (breaking changes)"
echo "2) Minor: ${GREEN}${NEXT_MINOR}${NC} (new features) [default]"
echo "3) Patch: ${GREEN}${NEXT_PATCH}${NC} (bug fixes)"

read -p $'\nChoice (1-3) [2]: ' VERSION_TYPE
VERSION_TYPE=${VERSION_TYPE:-2}

case $VERSION_TYPE in
    1) NEW_VERSION=$NEXT_MAJOR ;;
    2) NEW_VERSION=$NEXT_MINOR ;;
    3) NEW_VERSION=$NEXT_PATCH ;;
    *) NEW_VERSION=$NEXT_MINOR ;;
esac

echo -e "\n${BLUE}Analyzing changes since ${CURRENT_VERSION}...${NC}\n"

# Get the diff
DIFF=$(git log ${CURRENT_VERSION}..HEAD --pretty=format:"%s" --no-merges)
FILE_CHANGES=$(git diff ${CURRENT_VERSION}..HEAD --stat | head -20)

if [ -z "$DIFF" ]; then
    echo -e "${YELLOW}⚠️  No changes since last tag${NC}"
    exit 1
fi

echo "Recent commits:"
echo "$DIFF"
echo ""

# Prepare the prompt
FULL_DIFF=$(git log ${CURRENT_VERSION}..HEAD --pretty=format:"%h %s" --no-merges | head -20)

PROMPT="Analyze these git changes for a macOS clipboard manager app called SimpleCP and generate:
1. A concise release title (max 6 words, no version number)
2. 3-5 bullet points describing the changes (focus on user-facing features)

Recent commits:
$FULL_DIFF

Files modified:
$FILE_CHANGES

Format your response EXACTLY as:
TITLE: [your title here]
NOTES:
- [bullet point 1]
- [bullet point 2]
- [bullet point 3]

Be concise and focus on what users will experience."

# Try to get AI response
AI_OUTPUT=$(call_ai "$PROMPT")

if [ ! -z "$AI_OUTPUT" ] && [ "$AI_OUTPUT" != "null" ]; then
    # Parse AI output
    RELEASE_TITLE=$(echo "$AI_OUTPUT" | grep "TITLE:" | sed 's/TITLE: //' | sed 's/^[[:space:]]*//')
    RELEASE_NOTES=$(echo "$AI_OUTPUT" | sed -n '/NOTES:/,$p' | tail -n +2)
    
    if [ ! -z "$RELEASE_TITLE" ]; then
        echo -e "${GREEN}✨ AI-generated release notes:${NC}\n"
        echo -e "Title: ${YELLOW}${RELEASE_TITLE}${NC}"
        echo -e "\nNotes:"
        echo "$RELEASE_NOTES"
        echo ""
        
        read -p "Use these notes? (y/n/e) [y=yes, n=manual, e=edit]: " USE_AI_NOTES
        USE_AI_NOTES=${USE_AI_NOTES:-y}
        
        if [[ $USE_AI_NOTES == "e" ]]; then
            echo "Enter your edits:"
            read -p "Title: " -i "$RELEASE_TITLE" -e RELEASE_TITLE
            echo "Notes (one per line, empty line to finish):"
            RELEASE_NOTES=""
            while IFS= read -r line; do
                [[ -z "$line" ]] && break
                RELEASE_NOTES="${RELEASE_NOTES}- ${line}\n"
            done
        elif [[ $USE_AI_NOTES == "n" ]]; then
            RELEASE_TITLE=""
        fi
    else
        echo -e "${YELLOW}⚠️  Could not parse AI output${NC}"
        RELEASE_TITLE=""
    fi
else
    echo -e "${YELLOW}⚠️  No AI service available. Set up one of:${NC}"
    echo "  • Ollama (local): brew install ollama && ollama pull llama3.2"
    echo "  • Groq (free): export GROQ_API_KEY='your-key' (get at groq.com)"
    echo "  • OpenRouter (free): export OPENROUTER_API_KEY='your-key' (get at openrouter.ai)"
    echo "  • Hugging Face: export HUGGINGFACE_API_KEY='your-key' (get at huggingface.co)"
    echo ""
fi

# Manual input if no title yet
if [ -z "$RELEASE_TITLE" ]; then
    read -p "Enter release title: " RELEASE_TITLE
    echo "Enter release notes (one per line, empty line to finish):"
    RELEASE_NOTES=""
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        RELEASE_NOTES="${RELEASE_NOTES}- ${line}\n"
    done
fi

# Show summary
echo -e "\n${BLUE}=== Release Summary ===${NC}"
echo -e "Version: ${GREEN}${NEW_VERSION}${NC}"
echo -e "Title: ${RELEASE_TITLE}"
echo -e "\nNotes:"
echo -e "${RELEASE_NOTES}"

read -p $'\nProceed with tagging and push? (y/n): ' CONFIRM

if [[ $CONFIRM != "y" ]]; then
    echo "Aborted."
    exit 0
fi

# Create tag
TAG_MESSAGE="Feature Release ${NEW_VERSION} - ${RELEASE_TITLE}

${RELEASE_NOTES}"

git tag -a $NEW_VERSION -m "$TAG_MESSAGE"

# Push
echo -e "\n${BLUE}Pushing to remote...${NC}"
git push origin main
git push origin $NEW_VERSION

echo -e "\n${GREEN}✅ Successfully tagged and pushed ${NEW_VERSION}${NC}"
echo -e "\n${BLUE}Tag message:${NC}"
echo "$TAG_MESSAGE"

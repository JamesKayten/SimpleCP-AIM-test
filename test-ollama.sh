#!/bin/bash
PROMPT="Generate a git commit message for: Added flyout menus"
RESPONSE=$(curl -s http://localhost:11434/api/generate -d "{\"model\":\"llama3.2\",\"prompt\":\"$PROMPT\",\"stream\":false}")
echo "$RESPONSE" | jq -r '.response'

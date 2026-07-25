#!/bin/bash

# =====================================================================
# CONFIGURATION: INSERT YOUR GEMINI API KEY BELOW
# =====================================================================
API_KEY=""
DEFAULT_MODEL="gemini-3.5-flash-lite"
# =====================================================================

MODEL=$DEFAULT_MODEL

# We will store the conversation history in this temporary JSON array
HISTORY="[]"

# Colors for a pretty terminal UI
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}===========================================${NC}"
echo -e "${CYAN}      Gemini Bash CLI Interactive Chat     ${NC}"
echo -e "${CYAN}===========================================${NC}"
echo -e "Current Model: ${GREEN}$MODEL${NC}"
echo -e "${YELLOW}Commands:${NC}"
echo -e "  /model <name>  : Change model (e.g., /model gemini-2.5-flash)"
echo -e "  /clear         : Clear screen and reset memory"
echo -e "  /quit          : Exit the chat\n"

# The main chat loop
while true; do
    echo -e -n "${CYAN}You: ${NC}"
    read -r USER_INPUT

    # Ignore empty input
    if [[ -z "$USER_INPUT" ]]; then
        continue
    fi

    # Handle /quit
    if [[ "$USER_INPUT" == "/quit" || "$USER_INPUT" == "/exit" ]]; then
        echo -e "\n${CYAN}Goodbye! 👋${NC}\n"
        exit 0
    fi

    # Handle /clear
    if [[ "$USER_INPUT" == "/clear" ]]; then
        clear
        HISTORY="[]"
        echo -e "${CYAN}===========================================${NC}"
        echo -e "${CYAN}   🤖 Gemini Bash CLI Interactive Chat     ${NC}"
        echo -e "${CYAN}===========================================${NC}"
        echo -e "Current Model: ${GREEN}$MODEL${NC} (Memory Cleared)\n"
        continue
    fi

    # Handle /model change
    if [[ "$USER_INPUT" == /model* ]]; then
        NEW_MODEL=$(echo "$USER_INPUT" | awk '{print $2}')
        if [[ -n "$NEW_MODEL" ]]; then
            MODEL="$NEW_MODEL"
            HISTORY="[]" # Reset history when changing models to avoid context errors
            echo -e "${GREEN}✔ Model switched to: $MODEL (History reset)${NC}\n"
        else
            echo -e "${RED}Usage: /model <model_name>${NC}\n"
        fi
        continue
    fi

    # 1. Format the new user message into JSON
    NEW_MESSAGE=$(jq -n --arg text "$USER_INPUT" '{role: "user", parts: [{text: $text}]}')

    # 2. Append the new message to our history array
    HISTORY=$(echo "$HISTORY" | jq --argjson new_msg "$NEW_MESSAGE" '. + [$new_msg]')

    # 3. Build the final JSON payload
    PAYLOAD=$(jq -n --argjson history "$HISTORY" '{contents: $history}')

    # 4. Make the API Call to Google
    URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}"
    
    # We use a temporary file to capture the curl output safely
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$URL")
    
    # Extract the HTTP status code (last line) and the body (everything else)
    HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [[ "$HTTP_STATUS" != "200" ]]; then
        echo -e "\n${RED}API Error (HTTP $HTTP_STATUS):${NC}"
        echo "$BODY" | jq -r '.error.message // empty'
        echo ""
        
        # Remove the last user message from history since it failed
        HISTORY=$(echo "$HISTORY" | jq 'del(.[-1])')
        continue
    fi

    # 5. Extract the Gemini response text using jq
    REPLY_TEXT=$(echo "$BODY" | jq -r '.candidates[0].content.parts[0].text // empty')

    if [[ -n "$REPLY_TEXT" ]]; then
        echo -e "\n${CYAN}Gemini:${NC}"
        echo -e "$REPLY_TEXT\n"

        # 6. Append Gemini's reply to the history array so it remembers context
        ASSISTANT_MESSAGE=$(jq -n --arg text "$REPLY_TEXT" '{role: "model", parts: [{text: $text}]}')
        HISTORY=$(echo "$HISTORY" | jq --argjson new_msg "$ASSISTANT_MESSAGE" '. + [$new_msg]')
    else
        echo -e "\n${RED}Error: Received an empty response or failed to parse JSON.${NC}\n"
    fi

done

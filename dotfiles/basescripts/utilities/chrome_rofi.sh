#!/bin/bash

# Define the list of websites
declare -A websites=(
  ["ChatGPT"]="https://chat.openai.com"
  ["Claude"]="https://claude.ai"
  ["TheB.ai"]="https://theb.ai.com"
  ["Notion"]="https://www.notion.so"
  ["Google Calendar"]="https://calendar.google.com"
  ["WhatsApp Web"]="https://web.whatsapp.com"
  ["Google Keep"]="https://keep.google.com"
  ["LinkedIn"]="https://www.linkedin.com"
  ["Google Drive"]="https://drive.google.com"
  ["Gmail"]="https://mail.google.com"
  ["YouTube"]="https://www.youtube.com"
  ["GeeksForGeeks"]="https://www.geeksforgeeks.org"
  ["Striver's SDE Sheet"]="https://takeuforward.org/interviews/strivers-sde-sheet-top-150-most-important-questions/"
)

# Use rofi to select a website with case-insensitive fuzzy search
chosen=$(printf '%s\n' "${!websites[@]}" | rofi -dmenu -i -p "Open Website:")

# If a valid website is selected, open it in Chrome
if [[ -n "$chosen" ]]; then
  url="${websites[$chosen]}"
  # Open in Chrome
  google-chrome-stable "$url"
fi


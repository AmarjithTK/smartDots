#!/bin/bash

# Define an associative array to store website URLs and icons
declare -A websites
websites=(
  ["Stack Overflow"]="https://stackoverflow.com/"
  ["todolist"]="https://www.notion.so/Tasklist-a50f57b1557843d78543a75beb77b30b"
  ["GitHub"]="https://github.com/"
  ["W3Schools"]="https://www.w3schools.com/"
  ["GeeksforGeeks"]="https://www.geeksforgeeks.org/"
  ["Codecademy"]="https://www.codecademy.com/"
  ["Udemy"]="https://www.udemy.com/"
  ["Coursera"]="https://www.coursera.org/"
  ["Pluralsight"]="https://www.pluralsight.com/"
  ["HackerRank"]="https://www.hackerrank.com/"
  ["LeetCode"]="https://leetcode.com/"
  ["CodePen"]="https://codepen.io/"
  ["CSS-Tricks"]="https://css-tricks.com/"
  ["MDN Web Docs"]="https://developer.mozilla.org/"
  ["Google Developers"]="https://developers.google.com/"
  ["Microsoft Developer Network"]="https://developer.microsoft.com/"
  ["JetBrains"]="https://www.jetbrains.com/"
  ["Docker"]="https://www.docker.com/"
  ["AWS"]="https://aws.amazon.com/"
  ["Heroku"]="https://www.heroku.com/"
  ["DigitalOcean"]="https://www.digitalocean.com/"
  ["Firebase"]="https://firebase.google.com/"
  ["Netlify"]="https://www.netlify.com/"
  ["Cloudflare"]="https://www.cloudflare.com/"
  ["StackShare"]="https://stackshare.io/"
  ["Reddit"]="https://www.reddit.com/r/learnprogramming/"
  ["Medium"]="https://medium.com/topic/programming"
  ["FreeCodeCamp"]="https://www.freecodecamp.org/"
  ["The Odin Project"]="https://www.theodinproject.com/"
  ["Full Stack Python"]="https://www.fullstackpython.com/"
  ["Real Python"]="https://realpython.com/"
  ["Perplexity"]="https://perplexity.ai"
  ["Mail"]="https://mail.google.com/"
  ["ChatGPT"]="https://www.chatgpt.com"
  ["YouTube"]="https://www.youtube.com"
  ["Google News"]="https://news.google.com"
  ["Notion"]="https://www.notion.so"
)

# Initialize a variable to store Rofi options
rofi_options=""

# Loop through the websites and add them to the Rofi options
for key in "${!websites[@]}"; do
  rofi_options="$rofi_options$key\n"
done

# Show Rofi menu to select a website
chosen_website=$(echo -e "$rofi_options" | rofi -dmenu -p "Choose a website:" -i)

# Check if the user chose a valid website
if [[ -n "${websites[$chosen_website]}" ]]; then
  # Open the chosen website in Google Chrome
  google-chrome-stable "${websites[$chosen_website]}"
else
  # Display an error message if an invalid choice was made
  echo "Invalid selection: $chosen_website"
fi

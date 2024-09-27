#!/bin/bash

IMAGE_PATH="$HOME/.wallpapers/default.jpg"
feh --bg-fill "$IMAGE_PATH"
# Load environment variables from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Check if the PEXELS_KEY environment variable is set
if [ -z "$PEXELS_KEY" ]; then
  echo "PEXELS_KEY environment variable is not set."
  exit 1
fi

# Fetch a random cat image from Pexels
IMAGE_URL=$(curl -s "https://api.pexels.com/v1/search?query=army+with+weapon+special+forces&per_page=1&page=$((RANDOM % 100 + 1))" -H "Authorization: $PEXELS_KEY" | jq -r '.photos[0].src.original')

# Check if the image URL was fetched successfully
if [ -z "$IMAGE_URL" ]; then
  echo "Failed to fetch cat image."
  exit 1
fi

# Define the path to save the image

# Download the image
curl -s -o "$IMAGE_PATH" "$IMAGE_URL"

# Set the downloaded image as wallpaper using feh

echo "Cat wallpaper set successfully!"

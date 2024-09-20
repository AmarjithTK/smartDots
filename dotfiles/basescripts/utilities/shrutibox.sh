#!/bin/bash

# Path to the song file
SONG_PATH="$HOME/.helpers/musics/a_sharp.mp3"

# Check if mpv is running with the song
if pgrep -f "mpv --loop=inf $SONG_PATH" > /dev/null; then
    # If it's playing, kill the process to stop the song
    pkill -f "mpv --loop=inf $SONG_PATH"
else
    # If it's not playing, start playing the song in an infinite loop
    mpv --loop=inf "$SONG_PATH" &
fi


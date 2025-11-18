#!/bin/bash
echo "Enter URL to download"
read url
echo "Downloading with yt-dlp..."
yt-dlp -f 'bestaudio*' --extract-audio --audio-format mp3 -P ~/Downloads "$url" --no-playlist

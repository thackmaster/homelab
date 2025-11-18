This folder contains scripts that may be useful for homelab purposes or otherwise useful to me one way or another.

- `compress.sh` - Shell script that will take a folder of .mkv or .mp4 files and compress it to the best 1080p version it can using Handbrake-CLI. Script is dynamic enough to recognize if it is running on a Mac or Linux-based host and adjusts commands to accommodate. It assumes Handbrake-CLI is already installed on the host, and will not attempt to install it on its own.
- `yt-dlp.sh` - Shell script I use to download audio from various sources in the best quality. This script only makes me run one command without needing to adjust it with a different URL each time since the script prompts for it. Assumes yt-dlp is installed and environment is Mac.

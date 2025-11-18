#!/bin/bash
# USAGE: ./compress.sh /path/to/folder

# --- Input handling ---
# Must not be blank
INPUT_DIR="$1"
if [ -z "$INPUT_DIR" ]; then
	echo "Usage: $0 <input-folder>"
	exit 1
fi

# --- OS Detection ---
OS=$(uname)
if [[ "$OS" == "Darwin" ]]; then
	HANDBRAKE_CMD="handbrakecli"
	VIDEO_ENCODERS=("vt_h264")
	FILES=()
	while IFS= read -r file; do
		FILES+=("$file")
	done < <(find "$INPUT_DIR" -type f '(' -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" ')' | sort )
elif [[ "$OS" == "Linux" ]]; then
	HANDBRAKE_CMD="HandBrakeCLI"
	VIDEO_ENCODERS=("qsv_h264" "x264")
	mapfile -d '' FILES < <(find "$INPUT_DIR" -type f '(' -name "*.mp4" -o -name "*.mkv" -o -name "*.avi" ')' -print0 | sort -z )
else
	echo "Unsupported operating system: $OS"
	exit 1
fi

# --- Output directory ---
OUTPUT_DIR="output"
mkdir -p "$OUTPUT_DIR"

# --- Processing ---
for f in "${FILES[@]}"; do
	filename=$(basename "$f")
	base="${filename%.*}"
	output_file="$OUTPUT_DIR/$base.mkv"

	echo "Processing: $filename"

	success=false
	for encoder in "${VIDEO_ENCODERS[@]}"; do
		echo "Trying encoder: $encoder"
		"$HANDBRAKE_CMD" -i "$f" -o "$output_file" -e "$encoder" --aencoder copy --optimize --preset "Very Fast 1080p30"
		if [ $? -eq 0 ]; then
			echo "Success with encoder: $encoder"
			mv "$f" "$f.original"
			mv "$output_file" "$f"
			rm -f "$f.original"
			echo "Replaced original file"
			success=true
			break
		else
			echo "Failed with encoder: $encoder"
		fi
	done
	
	if ! $success; then
		echo "All encoders failed for $f"
	fi
done

# find "$INPUT_DIR" -type f \( -name "*.mp4" -o -name "*.mkv" \) -print0 | while IFS= read -r -d '' f; do
# 	filename=$(basename "$f")
# 	echo "Processing: $filename"
# 	"$HANDBRAKE_CMD" -i "$f" -o "$OUTPUT_DIR/$filename" -e vt_h264 --aencoder copy --optimize --preset "Very Fast 1080p30"
# done

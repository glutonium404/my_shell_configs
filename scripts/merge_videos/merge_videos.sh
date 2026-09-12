#!/usr/bin/env bash
#
# merge_videos.sh
#
# Reads a JSON config file listing (text, video) pairs, and produces one
# final video: a black title card with the text, then the video, repeated
# for each entry, then compressed with your usual settings.
#
# Each entry can also have an optional "audio" field. If given, that audio
# file replaces the video's own audio track entirely.
#
# Usage:
#   ./merge_videos.sh [config.json]        Run the merge using this config (default: config.json)
#   ./merge_videos.sh -i                    Create a default config.json in the current directory
#   ./merge_videos.sh -i -y                 Same, but overwrite an existing config.json without asking
#
# Requires: ffmpeg, jq
#   (on WSL: sudo apt install ffmpeg jq)

set -euo pipefail

# ---- What a fresh config.json looks like ----
read -r -d '' DEFAULT_CONFIG << 'EOF' || true
{
    "title_duration": 3,
    "resolution": "1920x1080",
    "fps": 30,
    "font_file": "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "font_size": 60,
    "crf": 28,
    "codec": "libx265",
    "blur_strength": 25,
    "dim_amount": -0.05,
    "output": "final_output.mp4",
    "entries": [
        { "text": "Video 1", "video": "video1.mp4" },
        { "text": "Video 2 With Audio", "video": "video2.mp4", "audio": "audio.mp3" }
    ]
}
EOF

print_help() {
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
}

run_init() {
    local target="config.json"

    if [[ -f "$target" ]]; then
        if [[ "$FORCE_YES" == true ]]; then
            echo "config.json already exists, overwriting (because of -y)."
        else
            read -r -p "config.json already exists. Overwrite? [y/N] " answer
            if [[ ! "$answer" =~ ^[Yy]$ ]]; then
                target="config_$(date +%Y%m%d_%H%M%S).json"
                echo "Keeping the existing file. Writing a new one to $target instead."
            fi
        fi
    fi

    printf '%s\n' "$DEFAULT_CONFIG" > "$target"
    echo "Config written to: $(pwd)/$target"
}

# ---- Parse flags ----
INIT_MODE=false
FORCE_YES=false
CONFIG_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--init)
            INIT_MODE=true
            shift
            ;;
        -y|--yes)
            FORCE_YES=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            CONFIG_ARG="$1"
            shift
            ;;
    esac
done

if [[ "$INIT_MODE" == true ]]; then
    run_init
    exit 0
fi

CONFIG="${CONFIG_ARG:-config.json}"

if [[ ! -f "$CONFIG" ]]; then
    echo "Config file not found: $CONFIG"
    echo "Tip: run '$0 -i' to generate a default one here."
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is not installed. Run: sudo apt install jq"
    exit 1
fi

# ---- Read settings from the config file ----
duration=$(jq -r '.title_duration' "$CONFIG")
resolution=$(jq -r '.resolution' "$CONFIG")
fps=$(jq -r '.fps' "$CONFIG")
font_file=$(jq -r '.font_file' "$CONFIG")
font_size=$(jq -r '.font_size' "$CONFIG")
blur_strength=$(jq -r '.blur_strength // 20' "$CONFIG")
dim_amount=$(jq -r '.dim_amount // -0.3' "$CONFIG")
crf=$(jq -r '.crf' "$CONFIG")
codec=$(jq -r '.codec' "$CONFIG")
output=$(jq -r '.output' "$CONFIG")

# Fixed audio settings so every clip (title cards + videos) matches exactly.
# This is required for the fast "concat" step to work.
audio_rate=48000
audio_channels=2

# scale/pad filters want "1920:1080" not "1920x1080"
res_colon="${resolution//x/:}"

entry_count=$(jq '.entries | length' "$CONFIG")
if [[ "$entry_count" -eq 0 ]]; then
    echo "No entries found in config."
    exit 1
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

concat_list="$workdir/concat_list.txt"
> "$concat_list"

for ((i = 0; i < entry_count; i++)); do
    text=$(jq -r ".entries[$i].text" "$CONFIG")
    video=$(jq -r ".entries[$i].video" "$CONFIG")
    audio=$(jq -r ".entries[$i].audio // empty" "$CONFIG")

    if [[ ! -f "$video" ]]; then
        echo "Video not found, skipping: $video"
        continue
    fi

    if [[ -n "$audio" && ! -f "$audio" ]]; then
        echo "Audio file not found ($audio), using the video's own audio instead."
        audio=""
    fi

    title_clip="$workdir/title_$i.mp4"
    norm_clip="$workdir/video_$i.mp4"

    # Split into separate lines ourselves and draw each one as its own
    # drawtext filter, rather than relying on ffmpeg to interpret a newline
    # character (that behaves inconsistently across ffmpeg builds/versions).
    mapfile -t text_lines <<< "$text"
    num_lines=${#text_lines[@]}
    line_height=$(( font_size * 13 / 10 ))
    total_height=$(( line_height * num_lines ))

    drawtext_chain=""
    for ((li = 0; li < num_lines; li++)); do
        line_escaped=$(printf '%s' "${text_lines[$li]}" | sed "s/:/\\\\:/g; s/'/\\\\'/g")
        y_offset=$(( li * line_height ))
        drawtext_chain+=",drawtext=fontfile=${font_file}:text='${line_escaped}':fontcolor=white:fontsize=${font_size}:x=(w-text_w)/2:y=(h-${total_height})/2+${y_offset}"
    done

    echo "[$((i + 1))/$entry_count] Title card: $text"
    ffmpeg -y -hide_banner -loglevel error \
    -stream_loop -1 -i "$video" \
    -f lavfi -i "anullsrc=r=${audio_rate}:cl=stereo" \
    -t "$duration" \
    -vf "scale=${res_colon}:force_original_aspect_ratio=increase,crop=${res_colon},boxblur=${blur_strength}:5,eq=brightness=${dim_amount},fps=${fps}${drawtext_chain}" \
    -map 0:v -map 1:a \
    -c:v libx264 -preset fast -c:a aac -shortest "$title_clip"

    if [[ -n "$audio" ]]; then
        echo "[$((i + 1))/$entry_count] Normalizing: $video (audio replaced with: $audio)"
        # Match the audio's length to the video exactly: trim it if it's
        # longer, silence-pad it if it's shorter. Video length always wins.
        vid_dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$video")
        ffmpeg -y -hide_banner -loglevel error \
        -i "$video" -i "$audio" \
        -filter_complex "[0:v]scale=${res_colon}:force_original_aspect_ratio=decrease,pad=${res_colon}:(ow-iw)/2:(oh-ih)/2,fps=${fps}[vid];[1:a]atrim=0:${vid_dur},apad=whole_dur=${vid_dur},aformat=sample_rates=${audio_rate}:channel_layouts=stereo[aud]" \
        -map "[vid]" -map "[aud]" \
        -c:v libx264 -preset fast -c:a aac "$norm_clip"
    else
        echo "[$((i + 1))/$entry_count] Normalizing: $video"
        ffmpeg -y -hide_banner -loglevel error -i "$video" \
        -vf "scale=${res_colon}:force_original_aspect_ratio=decrease,pad=${res_colon}:(ow-iw)/2:(oh-ih)/2,fps=${fps}" \
        -ar "$audio_rate" -ac "$audio_channels" \
        -c:v libx264 -preset fast -c:a aac "$norm_clip"
    fi

    echo "file '$title_clip'" >> "$concat_list"
    echo "file '$norm_clip'" >> "$concat_list"
done

merged="$workdir/merged.mp4"
echo "Joining all clips together..."
ffmpeg -y -hide_banner -loglevel error -f concat -safe 0 -i "$concat_list" -c copy "$merged"

echo "Compressing final output (this is the slow step)..."
ffmpeg -y -hide_banner -loglevel error -i "$merged" -vcodec "$codec" -crf "$crf" "$output"

echo "Done. Output saved to: $output"

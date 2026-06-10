#!/usr/bin/env bash
set -euo pipefail

SPONSOR_VIDEO_URL="${SPONSOR_VIDEO_URL:-https://static-gamers-media.s3.us-east-1.amazonaws.com/V5.mp4}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/assets/media"
OUT_FILE="$OUT_DIR/sponsor_video.mp4"

mkdir -p "$OUT_DIR"

if [[ "${1:-}" != "--force" && -f "$OUT_FILE" ]]; then
  echo "Sponsor video already present at $OUT_FILE"
  exit 0
fi

echo "Downloading sponsor video from $SPONSOR_VIDEO_URL"
curl -fL "$SPONSOR_VIDEO_URL" -o "$OUT_FILE"
echo "Saved sponsor video to $OUT_FILE"

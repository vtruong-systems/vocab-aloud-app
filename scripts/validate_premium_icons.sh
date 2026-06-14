#!/usr/bin/env bash
set -euo pipefail

# Validate (and optionally normalize) premium profile icon PNGs.
#
# Usage:
#   ./scripts/validate_premium_icons.sh [DIR]
#   ./scripts/validate_premium_icons.sh --fix [DIR]
#
# Env overrides:
#   TARGET_SIZE=256 MAX_FILE_KB=150 REQUIRE_SQUARE=1 REQUIRE_ALPHA=1

FIX=0
if [[ "${1:-}" == "--fix" ]]; then
  FIX=1
  shift
fi

ICON_DIR="${1:-assets/icons/premium}"
TARGET_SIZE="${TARGET_SIZE:-256}"
MIN_SIZE="${MIN_SIZE:-256}"
MAX_SIZE="${MAX_SIZE:-512}"
MAX_FILE_KB="${MAX_FILE_KB:-150}"
REQUIRE_SQUARE="${REQUIRE_SQUARE:-1}"
REQUIRE_ALPHA="${REQUIRE_ALPHA:-1}"

if ! command -v ffprobe >/dev/null 2>&1; then
  echo "ffprobe not found. Install ffmpeg: brew install ffmpeg"
  exit 1
fi

if [[ "$FIX" == "1" ]] && ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install ffmpeg: brew install ffmpeg"
  exit 1
fi

if [[ ! -d "$ICON_DIR" ]]; then
  echo "Directory not found: $ICON_DIR"
  exit 1
fi

probe_icon() {
  local f="$1"
  IFS=',' read -r width height pix_fmt <<< "$(
    ffprobe -v error \
      -select_streams v:0 \
      -show_entries stream=width,height,pix_fmt \
      -of csv=p=0 \
      "$f"
  )"
}

file_kb_for() {
  local f="$1"
  echo $(( ($(stat -f%z "$f" 2>/dev/null || stat -c%s "$f") + 1023) / 1024 ))
}

# Sets: icon_ok (1=pass), icon_notes (array), width, height, pix_fmt, file_kb
evaluate_icon() {
  local f="$1"
  probe_icon "$f"
  file_kb="$(file_kb_for "$f")"
  icon_ok=1
  icon_notes=()

  if [[ "$REQUIRE_SQUARE" == "1" && "$width" != "$height" ]]; then
    icon_notes+=("not square (${width}x${height})")
    icon_ok=0
  fi

  if (( width < MIN_SIZE || height < MIN_SIZE )); then
    icon_notes+=("too small (min ${MIN_SIZE}px)")
    icon_ok=0
  fi
  if (( width > MAX_SIZE || height > MAX_SIZE )); then
    icon_notes+=("too large (max ${MAX_SIZE}px)")
    icon_ok=0
  fi
  if [[ "$TARGET_SIZE" != "0" && ( "$width" != "$TARGET_SIZE" || "$height" != "$TARGET_SIZE" ) ]]; then
    icon_notes+=("expected exactly ${TARGET_SIZE}x${TARGET_SIZE}")
    icon_ok=0
  fi

  if [[ "$REQUIRE_ALPHA" == "1" ]]; then
    case "$pix_fmt" in
      rgba|bgra|yuva420p|yuva422p|yuva444p|gbrap|gbrap16le|pal8) ;;
      *)
        icon_notes+=("no alpha channel (pix_fmt=$pix_fmt)")
        icon_ok=0
        ;;
    esac
  fi

  if (( file_kb > MAX_FILE_KB )); then
    icon_notes+=("file too big (${file_kb}KB > ${MAX_FILE_KB}KB)")
    icon_ok=0
  fi
}

normalize_icon() {
  local f="$1"
  local rel="${f#"$ICON_DIR"/}"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/premium-icon.XXXXXX.png")"

  evaluate_icon "$f"
  local before="${width}x${height}"
  local size_before="$file_kb"

  ffmpeg -y -v error -i "$f" \
    -vf "crop=min(iw\,ih):min(iw\,ih),scale=${TARGET_SIZE}:${TARGET_SIZE}" \
    -pix_fmt rgba \
    "$tmp"

  mv "$tmp" "$f"

  evaluate_icon "$f"
  echo "FIX  $rel  ${before} ${size_before}KB -> ${width}x${height} ${file_kb}KB"
}

collect_files() {
  shopt -s nullglob
  files=("$ICON_DIR"/*.png "$ICON_DIR"/*/*.png "$ICON_DIR"/*/*/*.png)
  shopt -u nullglob
}

collect_files

if (( ${#files[@]} == 0 )); then
  echo "No PNG files found under $ICON_DIR"
  exit 1
fi

if [[ "$FIX" == "1" ]]; then
  fixed=0
  skipped=0
  for f in "${files[@]}"; do
    evaluate_icon "$f"
    if (( icon_ok )); then
      ((skipped++)) || true
    else
      normalize_icon "$f"
      ((fixed++)) || true
    fi
  done

  if (( fixed > 0 )); then
    echo "Normalized $fixed icon(s) to ${TARGET_SIZE}x${TARGET_SIZE} ($skipped already valid)."
  else
    echo "All $skipped icon(s) already valid; nothing to normalize."
  fi
  echo
fi

failures=0
checked=0

for f in "${files[@]}"; do
  ((checked++)) || true
  evaluate_icon "$f"
  rel="${f#"$ICON_DIR"/}"

  if (( icon_ok )); then
    echo "OK   $rel  ${width}x${height}  ${file_kb}KB  $pix_fmt"
  else
    echo "FAIL $rel  ${width}x${height}  ${file_kb}KB  $pix_fmt  -> ${icon_notes[*]}"
    ((failures++)) || true
  fi
done

echo
echo "Checked $checked icon(s). Failures: $failures"

if (( failures > 0 )); then
  exit 1
fi

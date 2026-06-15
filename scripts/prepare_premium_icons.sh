#!/usr/bin/env bash
set -euo pipefail

# Normalize premium profile icons for in-app use and export store product
# images without alpha (gitignored under play-store/products/).
#
# Usage:
#   ./scripts/prepare_premium_icons.sh [ICON_DIR]
#   ./scripts/prepare_premium_icons.sh --play-store-only [ICON_DIR]
#
# Env overrides:
#   TARGET_SIZE=256          in-app icon size (see validate_premium_icons.sh)
#   PLAY_STORE_SIZE=1024     Play product image size (512-1080, 1:1)
#   PLAY_STORE_DIR=play-store/products

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/premium_icon_image.sh
source "$SCRIPT_DIR/lib/premium_icon_image.sh"
PLAY_STORE_ONLY=0

if [[ "${1:-}" == "--play-store-only" ]]; then
  PLAY_STORE_ONLY=1
  shift
fi

ICON_DIR="${1:-assets/icons/premium}"
ICON_DIR="$ROOT_DIR/$ICON_DIR"
PLAY_STORE_DIR="${PLAY_STORE_DIR:-$ROOT_DIR/play-store/products}"
PLAY_STORE_SIZE="${PLAY_STORE_SIZE:-1024}"
IAP_PRODUCTS_JSON="${IAP_PRODUCTS_JSON:-$ROOT_DIR/store/iap_products.json}"

if (( PLAY_STORE_SIZE < 512 || PLAY_STORE_SIZE > 1080 )); then
  echo "PLAY_STORE_SIZE must be between 512 and 1080 (got $PLAY_STORE_SIZE)"
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "magick not found. Install ImageMagick: brew install imagemagick"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found. Install jq: brew install jq"
  exit 1
fi

if [[ ! -d "$ICON_DIR" ]]; then
  echo "Directory not found: $ICON_DIR"
  exit 1
fi

product_id_for_icon() {
  local icon_id="$1"
  local product_id

  if [[ -f "$IAP_PRODUCTS_JSON" ]]; then
    product_id="$(jq -r --arg id "$icon_id" '
      .[] | select(.iconId == $id) | .productId
    ' "$IAP_PRODUCTS_JSON" | head -n 1)"
    if [[ -n "$product_id" && "$product_id" != "null" ]]; then
      echo "$product_id"
      return
    fi
  fi

  echo "vocab_icon_${icon_id}"
}

export_play_store_image() {
  local source="$1"
  local icon_id="$2"
  local product_id dest

  product_id="$(product_id_for_icon "$icon_id")"
  dest="$PLAY_STORE_DIR/${product_id}.png"
  mkdir -p "$PLAY_STORE_DIR"

  premium_icon_render_store "$source" "$dest" "$PLAY_STORE_SIZE"

  echo "PLAY $icon_id -> play-store/products/${product_id}.png (${PLAY_STORE_SIZE}x${PLAY_STORE_SIZE})"
}

shopt -s nullglob
icons=("$ICON_DIR"/*.png)
shopt -u nullglob

if (( ${#icons[@]} == 0 )); then
  echo "No PNG files found under $ICON_DIR"
  exit 1
fi

for icon in "${icons[@]}"; do
  icon_id="$(basename "$icon" .png)"
  export_play_store_image "$icon" "$icon_id"
done

if [[ "$PLAY_STORE_ONLY" == "0" ]]; then
  "$ROOT_DIR/scripts/validate_premium_icons.sh" --fix "$ICON_DIR"
else
  echo
  echo "Skipped in-app normalization (--play-store-only)."
fi

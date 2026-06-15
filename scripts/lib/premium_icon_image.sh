#!/usr/bin/env bash

# Shared ImageMagick helpers for premium profile icons.

_premium_icon_corner_max() {
  local img="$1"
  local geom="$2"
  magick "$img" -crop "$geom" +repage \
    -channel RGB -separate -evaluate-sequence max \
    -format '%[fx:maxima]' info:
}

_premium_icon_edge_min() {
  local img="$1"
  local geom="$2"
  magick "$img" -crop "$geom" +repage \
    -channel RGB -separate -evaluate-sequence min \
    -format '%[fx:minima]' info:
}

premium_icon_needs_squircle_crop() {
  local img="$1"
  local w h cx cy
  w="$(magick "$img" -format '%w' info:)"
  h="$(magick "$img" -format '%h' info:)"
  cx=$((w / 2))
  cy=$((h / 2))

  _premium_icon_is_dark "$(_premium_icon_corner_max "$img" "1x1+0+0")" || return 1
  _premium_icon_is_dark "$(_premium_icon_corner_max "$img" "1x1+$((w - 1))+0")" || return 1
  _premium_icon_is_dark "$(_premium_icon_corner_max "$img" "1x1+0+$((h - 1))")" || return 1
  _premium_icon_is_dark "$(_premium_icon_corner_max "$img" "1x1+$((w - 1))+$((h - 1))")" || return 1

  _premium_icon_is_light "$(_premium_icon_edge_min "$img" "1x1+${cx}+0")" || return 1
  _premium_icon_is_light "$(_premium_icon_edge_min "$img" "1x1+${cx}+$((h - 1))")" || return 1
  _premium_icon_is_light "$(_premium_icon_edge_min "$img" "1x1+0+${cy}")" || return 1
  _premium_icon_is_light "$(_premium_icon_edge_min "$img" "1x1+$((w - 1))+${cy}")" || return 1

  return 0
}

_premium_icon_is_dark() {
  awk "BEGIN { exit !($1 < 0.125) }"
}

_premium_icon_is_light() {
  awk "BEGIN { exit !($1 > 0.85) }"
}

premium_icon_find_squircle_crop_percent() {
  local img="$1"
  local min_pct="${2:-70}"
  local pct tmp

  if ! premium_icon_needs_squircle_crop "$img"; then
    echo "100"
    return
  fi

  for (( pct = 100; pct >= min_pct; pct-- )); do
    tmp="$(mktemp "${TMPDIR:-/tmp}/premium-icon-crop.XXXXXX.png")"
    magick "$img" -gravity center -crop "${pct}%x${pct}%+0+0" +repage "$tmp"
    if ! premium_icon_needs_squircle_crop "$tmp"; then
      rm -f "$tmp"
      echo "$pct"
      return
    fi
    rm -f "$tmp"
  done

  echo "100"
}

premium_icon_guess_background() {
  local img="$1"
  local w h cx cy edge_min

  w="$(magick "$img" -format '%w' info:)"
  h="$(magick "$img" -format '%h' info:)"
  cx=$((w / 2))
  cy=$((h / 2))

  edge_min="$(_premium_icon_edge_min "$img" "1x1+${cx}+0")"
  if _premium_icon_is_light "$edge_min"; then
    echo "white"
    return
  fi

  edge_min="$(_premium_icon_edge_min "$img" "1x1+0+${cy}")"
  if _premium_icon_is_light "$edge_min"; then
    echo "white"
    return
  fi

  echo "black"
}

premium_icon_render() {
  local source="$1"
  local dest="$2"
  local size="$3"
  local crop_pct

  crop_pct="$(premium_icon_find_squircle_crop_percent "$source")"

  magick "$source" \
    -gravity center -crop "${crop_pct}%x${crop_pct}%+0+0" +repage \
    -filter Lanczos \
    -resize "${size}x${size}!" \
    -define png:color-type=6 \
    "PNG32:$dest"
}

# Store product images must not include alpha (App Store / Play Console).
premium_icon_render_store() {
  local source="$1"
  local dest="$2"
  local size="$3"
  local crop_pct bg preview

  crop_pct="$(premium_icon_find_squircle_crop_percent "$source")"
  preview="$(mktemp "${TMPDIR:-/tmp}/premium-icon-preview.XXXXXX.png")"
  magick "$source" \
    -gravity center -crop "${crop_pct}%x${crop_pct}%+0+0" +repage \
    "$preview"
  bg="$(premium_icon_guess_background "$preview")"
  rm -f "$preview"

  magick "$source" \
    -gravity center -crop "${crop_pct}%x${crop_pct}%+0+0" +repage \
    -filter Lanczos \
    -resize "${size}x${size}!" \
    -background "$bg" -alpha remove -alpha off \
    -define png:color-type=2 \
    "PNG24:$dest"
}

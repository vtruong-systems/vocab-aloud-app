#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
dart run "$ROOT_DIR/tool/generate_vocabulary.dart"
"$ROOT_DIR/scripts/download_sponsor_video.sh" "$@"

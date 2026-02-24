#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$ROOT_DIR/addon"
BUILD_DIR="$ROOT_DIR/build"
STAGE_DIR="$BUILD_DIR/BaroCM"
ZIP_PATH="$BUILD_DIR/BaroCM.zip"

if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory not found: $SRC_DIR" >&2
  exit 1
fi

rm -rf "$STAGE_DIR" "$ZIP_PATH"
mkdir -p "$BUILD_DIR"
cp -R "$SRC_DIR" "$STAGE_DIR"

if command -v zip >/dev/null 2>&1; then
  (
    cd "$BUILD_DIR"
    zip -r "$(basename "$ZIP_PATH")" "$(basename "$STAGE_DIR")"
  )
elif command -v powershell.exe >/dev/null 2>&1; then
  powershell.exe -NoProfile -Command "Compress-Archive -Path '$STAGE_DIR' -DestinationPath '$ZIP_PATH' -Force"
elif command -v 7z >/dev/null 2>&1; then
  (
    cd "$BUILD_DIR"
    7z a -tzip "$(basename "$ZIP_PATH")" "$(basename "$STAGE_DIR")" >/dev/null
  )
else
  echo "No zip tool found. Install 'zip', '7z', or run where 'powershell.exe' is available." >&2
  exit 1
fi

if [ ! -f "$ZIP_PATH" ]; then
  echo "Archive was not created: $ZIP_PATH" >&2
  exit 1
fi

echo "Created $ZIP_PATH"
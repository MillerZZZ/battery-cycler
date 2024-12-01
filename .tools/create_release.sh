#!/bin/bash

ARCHIVE_NAME="release_$(date +%Y%m%d%H%M%S).zip"
RELEASE_DIR="./release/"
REAL_PATH="$(realpath "$RELEASE_DIR")/$ARCHIVE_NAME"

TEMP_DIR=$(mktemp -d)
rsync -av --exclude-from=./.tools/release_ignore.txt ./ "$TEMP_DIR/"
cd "$TEMP_DIR"
zip -r "$REAL_PATH" ./*

rm -rf "$TEMP_DIR"

echo "Archive created at $(echo "$RELEASE_DIR/$ARCHIVE_NAME" | awk '{gsub(/\/+/, "/"); print}')"
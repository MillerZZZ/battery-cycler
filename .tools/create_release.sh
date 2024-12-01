#!/bin/bash

ARCHIVE_NAME="release_$(date +%Y%m%d%H%M%S).zip"
RELEASE_DIR="./release"
REAL_PATH="$(realpath "$RELEASE_DIR")/$ARCHIVE_NAME"

TEMP_DIR=$(mktemp -d)
rsync -av --exclude-from=.gitignore --exclude=".git" --exclude=".tools" ./ "$TEMP_DIR/"

cd "$TEMP_DIR"
zip -r "$REAL_PATH" ./*
cd -

rm -rf "$TEMP_DIR"

echo "Archive created at $RELEASE_DIR/$ARCHIVE_NAME"
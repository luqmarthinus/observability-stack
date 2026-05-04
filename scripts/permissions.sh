#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/observability"

chmod 755 "$BASE_DIR"
chmod 755 "$BASE_DIR"/{compose,stack,scripts,docs}

find "$BASE_DIR/stack" -type f -name "*.yml" -exec chmod 644 {} \;

chmod -R 700 "$BASE_DIR/secrets"
chmod 600 "$BASE_DIR/secrets"/* 2>/dev/null || true

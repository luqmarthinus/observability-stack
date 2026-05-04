#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/observability"

mkdir -p "$BASE_DIR/secrets"

openssl rand -base64 32 > "$BASE_DIR/secrets/grafana_admin_password"
chmod 600 "$BASE_DIR/secrets/grafana_admin_password"

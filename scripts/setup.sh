#!/usr/bin/env bash
set -e

BASE_DIR="$HOME/observability"

mkdir -p "$BASE_DIR"/stack/{prometheus/rules,grafana/provisioning,loki,promtail,tempo}

touch "$BASE_DIR/docker-compose.yml"

touch "$BASE_DIR/stack/prometheus/prometheus.yml"
touch "$BASE_DIR/stack/loki/loki.yml"
touch "$BASE_DIR/stack/promtail/promtail.yml"
touch "$BASE_DIR/stack/tempo/tempo.yml"

echo "done"

#!/usr/bin/env bash
# ------------------------------------------------------------------
# uninstall.sh - Completely remove the observability stack from Docker
#                and delete the generated Grafana password file.
# ------------------------------------------------------------------
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="${ROOT_DIR}/secrets"
COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml"

echo "Cleaning up observability stack..."

# 1. Take down containers, remove networks and volumes (including orphans)
if docker compose version &> /dev/null; then
    cd "${ROOT_DIR}"
    docker compose down --remove-orphans -v 2>/dev/null || true
    echo "Docker Compose services, networks, and volumes removed."
else
    echo "WARNING: docker compose not found. Skipping Docker cleanup." >&2
fi

# 2. Remove the generated Grafana password file
if [ -f "${SECRETS_DIR}/grafana_admin_password" ]; then
    rm -f "${SECRETS_DIR}/grafana_admin_password"
    echo "Removed ${SECRETS_DIR}/grafana_admin_password"
fi

# 3. Remove the entire secrets directory if empty
if [ -d "${SECRETS_DIR}" ] && [ -z "$(ls -A "${SECRETS_DIR}" 2>/dev/null)" ]; then
    rmdir "${SECRETS_DIR}" 2>/dev/null || true
    echo "Removed empty secrets directory."
fi

echo "Cleanup complete."
#!/usr/bin/env bash
# ================================================================
# setup.sh – Initialisation for the observability stack
# ================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_DIR="${ROOT_DIR}/stack"
SECRETS_DIR="${ROOT_DIR}/secrets"
SCRIPTS_DIR="${ROOT_DIR}/scripts"

# ── Prerequisite checks ─────────────────────────────────────────
check_deps() {
  echo "Checking prerequisites..."
  for cmd in docker curl; do
    if ! command -v "$cmd" &> /dev/null; then
      echo "ERROR: $cmd is required but not installed." >&2
      exit 1
    fi
  done

  if ! docker compose version &> /dev/null; then
    echo "ERROR: docker compose (v2) is not available." >&2
    exit 1
  fi

  echo "All prerequisites are satisfied."
}

# ── Generate Grafana admin password secret ──────────────────────
init_secrets() {
  mkdir -p "${SECRETS_DIR}"
  if [[ ! -f "${SECRETS_DIR}/grafana_admin_password" ]]; then
    echo "Generating Grafana admin password..."
    openssl rand -base64 32 > "${SECRETS_DIR}/grafana_admin_password"
    chmod 600 "${SECRETS_DIR}/grafana_admin_password"
    echo "Secret stored in ${SECRETS_DIR}/grafana_admin_password"
  else
    echo "Grafana admin password already exists – skipping."
  fi
}

# ── Ensure required config directories exist ────────────────────
bootstrap_configs() {
  echo "Checking configuration directories..."
  mkdir -p "${STACK_DIR}/alloy"
  
  #validation checks can be added for mandatory config files here
  local required_files=(
    "${STACK_DIR}/prometheus/prometheus.yml"
    "${STACK_DIR}/loki/loki.yml"
    "${STACK_DIR}/alloy/config.alloy"
    "${STACK_DIR}/tempo/tempo.yml"
  )
  
  for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "ERROR: Required configuration file missing: $file" >&2
      exit 1
    fi
  done
  echo "All required configuration files are present."
}

# ── Set restrictive permissions on sensitive files ─────────────
set_permissions() {
  echo "Setting file permissions..."
  chmod 600 "${SECRETS_DIR}/grafana_admin_password" 2>/dev/null || true
  chmod 644 "${STACK_DIR}/prometheus/prometheus.yml" 2>/dev/null || true
  chmod 644 "${STACK_DIR}/loki/loki.yml" 2>/dev/null || true
  chmod 644 "${STACK_DIR}/alloy/config.alloy" 2>/dev/null || true
  chmod 644 "${STACK_DIR}/tempo/tempo.yml" 2>/dev/null || true
  echo "✔ Permissions set."
}

# ── Start the stack ─────────────────────────────────────────────
start_stack() {
  echo "Starting observability stack..."
  cd "${ROOT_DIR}"
  docker compose up -d --wait   # Waits for containers to be healthy
  echo "✔ Stack is running."
}

# ── Show access URLs ────────────────────────────────────────────
show_urls() {
  echo ""
  echo "=============================================="
  echo " Observability Stack – Access URLs"
  echo "=============================================="
  echo " Grafana:    http://localhost:3000  (admin / see secrets/grafana_admin_password)"
  echo " Prometheus: http://localhost:9090"
  echo " Loki:       http://localhost:3100"
  echo " Tempo:      http://localhost:3200"
  echo "=============================================="
}

# ── Main ────────────────────────────────────────────────────────
main() {
  check_deps
  init_secrets
  bootstrap_configs
  set_permissions
  start_stack
  show_urls
}

main "$@"

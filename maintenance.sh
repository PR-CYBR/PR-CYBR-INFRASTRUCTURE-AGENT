#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
MODE="manual"
if [[ "${CI:-}" == "true" || -n "${GITHUB_ACTIONS:-}" ]]; then
  MODE="ci"
fi

json_escape() {
  local str="$1"
  str="${str//\\/\\\\}"
  str="${str//\"/\\\"}"
  str="${str//$'\n'/\\n}"
  str="${str//$'\r'/\\r}"
  str="${str//$'\t'/\\t}"
  printf '%s' "$str"
}

log() {
  local level="$1"; shift
  local message="$1"; shift || true
  local timestamp
  timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  printf '{"timestamp":"%s","script":"%s","mode":"%s","level":"%s","message":"%s"' \
    "$(json_escape "$timestamp")" "$(json_escape "$SCRIPT_NAME")" "$(json_escape "$MODE")" \
    "$(json_escape "$level")" "$(json_escape "$message")"
  if [[ $# -gt 0 ]]; then
    printf ',"details":['
    local first=1
    local detail
    for detail in "$@"; do
      if [[ $first -eq 0 ]]; then
        printf ','
      fi
      printf '"%s"' "$(json_escape "$detail")"
      first=0
    done
    printf ']'
  fi
  printf '}'
  printf '\n'
}

handle_error() {
  local exit_code=$?
  log "ERROR" "Maintenance failed" "exit_code=$exit_code"
  exit "$exit_code"
}

trap handle_error ERR

check_dependency() {
  local dep="$1"
  if ! command -v "$dep" >/dev/null 2>&1; then
    log "ERROR" "Missing dependency" "dependency=$dep"
    return 1
  fi
  log "INFO" "Dependency present" "dependency=$dep"
}

run_optional() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    "$cmd" "$@"
  else
    log "WARNING" "Skipping optional command" "command=$cmd"
  fi
}

log "INFO" "Starting maintenance"

check_dependency "python3"
check_dependency "pip"

if [[ "$MODE" == "ci" ]]; then
  log "INFO" "Running CI maintenance tasks"
  run_optional "pytest" --maxfail=1 --disable-warnings -q
  log "INFO" "Completed test suite"
  run_optional "flake8" src tests
  log "INFO" "Completed linting"
else
  log "INFO" "Running manual maintenance tasks"
  if command -v "pytest" >/dev/null 2>&1; then
    pytest
    log "INFO" "Pytest finished"
  else
    log "WARNING" "Pytest not available; skipping"
  fi
  if command -v "flake8" >/dev/null 2>&1; then
    flake8 src tests
    log "INFO" "Flake8 finished"
  else
    log "WARNING" "Flake8 not available; skipping"
  fi
fi

log "INFO" "Maintenance completed successfully"

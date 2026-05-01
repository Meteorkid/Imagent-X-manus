#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

echo "[legacy-path-check] scanning curated files..."

targets=(
  "README.md"
  ".github/workflows"
  "scripts/core"
  "scripts/deployment"
  "docs/guides/START_GUIDE.md"
)

legacy_pattern='imagentx-frontend-plus'

if grep -RIn "$legacy_pattern" "${targets[@]}"; then
  echo ""
  echo "[legacy-path-check] Found legacy path '${legacy_pattern}'."
  echo "Please replace it with 'apps/frontend'."
  exit 1
fi

echo "[legacy-path-check] no legacy frontend path found."

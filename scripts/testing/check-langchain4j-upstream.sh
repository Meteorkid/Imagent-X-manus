#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
POM_FILE="$ROOT_DIR/apps/backend/pom.xml"

echo "[langchain4j-check] verify upstream coordinates in pom.xml..."

if grep -n "com.github.lucky-aeon.langchain4j" "$POM_FILE"; then
  echo ""
  echo "[langchain4j-check] Found legacy fork coordinate."
  echo "Please migrate to dev.langchain4j (方案 A)."
  exit 1
fi

echo "[langchain4j-check] upstream coordinates check passed."

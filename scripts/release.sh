#!/usr/bin/env bash
set -euo pipefail

if command -v node >/dev/null 2>&1; then
  node scripts/release.mjs "$@"
elif command -v node.exe >/dev/null 2>&1; then
  node.exe scripts/release.mjs "$@"
else
  echo "Error: node is required to run the release script" >&2
  exit 1
fi

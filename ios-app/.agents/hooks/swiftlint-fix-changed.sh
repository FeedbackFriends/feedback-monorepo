#!/usr/bin/env bash
set -euo pipefail

# Compatibility entry point for existing local callers. Linting never fixes files.
exec python3 "$(git rev-parse --show-toplevel)/ios-app/scripts/lint-swift-changes.py" "$@"

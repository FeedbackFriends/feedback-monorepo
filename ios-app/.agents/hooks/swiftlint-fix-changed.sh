#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)/ios-app"

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "swiftlint is required but not installed" >&2
  exit 1
fi

changed_files=$( {
  git diff --name-only -- '*.swift'
  git diff --name-only --cached -- '*.swift'
  git ls-files --others --exclude-standard -- '*.swift'
} | sort -u )

if [ -z "${changed_files}" ]; then
  exit 0
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [ -f "$file" ]; then
    swiftlint lint --fix "$file"
    swiftlint lint --strict "$file"
  fi
done <<< "$changed_files"

#!/bin/sh
set -euo pipefail

if [ "${TEST_RUNNER_CI:-}" = "TRUE" ]; then
  echo "Skipping pre-xcodebuild steps for test runner CI."
  exit 0
fi

CI_PRIMARY_REPOSITORY_PATH="${CI_PRIMARY_REPOSITORY_PATH:-$(pwd)}"
mkdir -p "$CI_PRIMARY_REPOSITORY_PATH/App/Config"
SECRETS_FILE="$CI_PRIMARY_REPOSITORY_PATH/App/Config/secrets.xcconfig"

{
  echo "SENTRY_DSN_URL = ${SENTRY_DSN_URL:-}"
  echo "SENTRY_DSN_SCHEME = ${SENTRY_DSN_SCHEME:-}"
  echo "API_BASE_URL = ${API_BASE_URL:-}"
  echo "FIREBASE_GOOGLE_APP_ID = ${FIREBASE_GOOGLE_APP_ID:-}"
  echo "FIREBASE_GCM_SENDER_ID = ${FIREBASE_GCM_SENDER_ID:-}"
  echo "FIREBASE_CLIENT_ID = ${FIREBASE_CLIENT_ID:-}"
  echo "FIREBASE_API_KEY = ${FIREBASE_API_KEY:-}"
  echo "FIREBASE_BUNDLE_ID = ${FIREBASE_BUNDLE_ID:-}"
  echo "FIREBASE_PROJECT_ID = ${FIREBASE_PROJECT_ID:-}"
  echo "FIREBASE_STORAGE_BUCKET = ${FIREBASE_STORAGE_BUCKET:-}"
} > "$SECRETS_FILE"

echo "✅ Wrote secrets to $SECRETS_FILE"

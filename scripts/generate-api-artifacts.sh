#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Generating canonical OpenAPI contract from backend..."
cd "$REPO_ROOT/backend"
SPRING_PROFILES_ACTIVE=openapi ./gradlew syncOpenApiSpec --no-configuration-cache

echo "Generating TypeScript API types..."
cd "$REPO_ROOT/web"
npm run generate:api-types

echo "Generating Swift OpenAPI sources..."
cd "$REPO_ROOT/ios-app/Modules"
swift package plugin --allow-writing-to-package-directory generate-code-from-openapi --target OpenAPI

echo "API artifacts are up to date."

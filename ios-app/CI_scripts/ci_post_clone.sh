#!/bin/sh
set -euo pipefail

if [ "${TEST_RUNNER_CI:-}" = "TRUE" ]; then
  echo "Skipping pre-xcodebuild steps for test runner CI."
  exit 0
fi

defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"

# --- get version from xcconfig ---
XCCONFIG="$CI_PRIMARY_REPOSITORY_PATH/ios-app/App/Config/default.xcconfig"
VERSION=$(grep '^MARKETING_VERSION' "$XCCONFIG" | cut -d= -f2 | tr -d '[:space:]')

[ -n "$VERSION" ] || { echo "ERROR: MARKETING_VERSION not found"; exit 1; }

# Tagging is optional and must not require a write token for internal testing.
if [ -z "${GITHUB_WRITE_PAT:-}" ]; then
  echo "Skipping Git tag creation: GITHUB_WRITE_PAT is not configured."
  exit 0
fi

: "${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is required for Git tagging}"

TAG="${VERSION}(${CI_BUILD_NUMBER})"
echo "Creating tag: $TAG"

cd "$CI_PRIMARY_REPOSITORY_PATH"

# Use the checked-out repository without persisting the token in its remote URL.
git tag "$TAG"
git -c credential.helper= \
  -c 'credential.helper=!f() { printf "%s\n" "username=x-access-token" "password=$GITHUB_WRITE_PAT"; }; f' \
  push origin "refs/tags/$TAG"

echo "✅ Successfully pushed tag $TAG"

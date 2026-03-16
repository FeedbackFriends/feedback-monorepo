#!/bin/sh
set -euo pipefail

if [ "${TEST_RUNNER_CI:-}" = "TRUE" ]; then
  echo "Skipping pre-xcodebuild steps for test runner CI."
  exit 0
fi

defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

: "${GITHUB_WRITE_PAT:?GITHUB_WRITE_PAT is required}"
: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"
: "${CI_BUILD_NUMBER:?CI_BUILD_NUMBER is required}"
: "${CI_BRANCH:=main}"

# --- get version from xcconfig ---
XCCONFIG="$CI_PRIMARY_REPOSITORY_PATH/Xcode_project/App/Config/default.xcconfig"
VERSION=$(grep '^MARKETING_VERSION' "$XCCONFIG" | cut -d= -f2 | tr -d '[:space:]')

[ -n "$VERSION" ] || { echo "ERROR: MARKETING_VERSION not found"; exit 1; }

TAG="${VERSION}(${CI_BUILD_NUMBER})"
echo "Creating tag: $TAG"

cd "$CI_PRIMARY_REPOSITORY_PATH"

git config user.email "ci@xcodecloud.apple.com"
git config user.name "XcodeCloud"
git remote set-url origin "https://${GITHUB_WRITE_PAT}@github.com/FeedbackFriends/feedback-ios.git"

git fetch --tags origin || true
git tag -f "$TAG"
git push --force origin "$TAG"

echo "✅ Successfully pushed tag $TAG"

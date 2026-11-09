#!/bin/sh
set -eu

# Local and simulator builds do not upload production diagnostics.
if [ "${CI_XCODE:-false}" != "true" ] || [ "${PLATFORM_NAME:-}" != "iphoneos" ]; then
  echo "Skipping Crashlytics symbol upload outside Xcode Cloud device builds."
  exit 0
fi

: "${FIREBASE_GOOGLE_APP_ID:?Firebase app ID is required for Crashlytics symbol upload}"
: "${BUILD_DIR:?Xcode build directory is required}"
: "${DWARF_DSYM_FOLDER_PATH:?dSYM directory is required}"
: "${DWARF_DSYM_FILE_NAME:?dSYM filename is required}"

if [ ! -d "$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME" ]; then
  echo "error: App dSYM is missing; Crashlytics symbol upload cannot proceed." >&2
  exit 1
fi

# Use the SDK already resolved by Xcode. Upload synchronously so failures are visible.
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
  -ai "$FIREBASE_GOOGLE_APP_ID" -p ios \
  "$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME"

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "upload-crashlytics-symbols.sh"


class CrashlyticsSymbolsTests(unittest.TestCase):
    def test_local_and_cloud_simulator_builds_skip_without_configuration(self):
        for environment in ({}, {"CI_XCODE": "true", "PLATFORM_NAME": "iphonesimulator"}):
            with self.subTest(environment=environment):
                result = subprocess.run(["/bin/sh", str(SCRIPT)], env=environment, capture_output=True)
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_cloud_device_build_requires_firebase_configuration(self):
        result = subprocess.run(
            ["/bin/sh", str(SCRIPT)],
            env={"CI_XCODE": "true", "PLATFORM_NAME": "iphoneos"},
            capture_output=True,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"Firebase app ID is required", result.stderr)

    def test_cloud_device_build_rejects_missing_symbols(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                ["/bin/sh", str(SCRIPT)],
                env={
                    "CI_XCODE": "true",
                    "PLATFORM_NAME": "iphoneos",
                    "FIREBASE_GOOGLE_APP_ID": "1:123:ios:abc",
                    "BUILD_DIR": str(Path(directory) / "Build/Products"),
                    "DWARF_DSYM_FOLDER_PATH": directory,
                    "DWARF_DSYM_FILE_NAME": "Missing.app.dSYM",
                },
                capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b"App dSYM is missing", result.stderr)

    def test_upload_uses_resolved_sdk_and_propagates_failure(self):
        with tempfile.TemporaryDirectory(prefix="Crashlytics symbols ") as directory:
            root = Path(directory)
            uploader = root / "SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
            uploader.parent.mkdir(parents=True)
            uploader.write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$ARGUMENTS_FILE"\nexit "$UPLOAD_EXIT_CODE"\n')
            uploader.chmod(0o755)
            arguments = root / "arguments"
            dsym = root / "Build/Products/Release-iphoneos/App.app.dSYM"
            dsym.mkdir(parents=True)
            environment = {
                "PATH": os.defpath,
                "CI_XCODE": "true",
                "PLATFORM_NAME": "iphoneos",
                "FIREBASE_GOOGLE_APP_ID": "1:123:ios:abc",
                "BUILD_DIR": str(root / "Build/Products"),
                "DWARF_DSYM_FOLDER_PATH": str(dsym.parent),
                "DWARF_DSYM_FILE_NAME": dsym.name,
                "ARGUMENTS_FILE": str(arguments),
            }
            for exit_code in (0, 7):
                with self.subTest(exit_code=exit_code):
                    result = subprocess.run(
                        ["/bin/sh", str(SCRIPT)],
                        env={**environment, "UPLOAD_EXIT_CODE": str(exit_code)},
                        capture_output=True,
                    )
                    self.assertEqual(result.returncode, exit_code, result.stderr)
                    self.assertEqual(
                        arguments.read_text().splitlines(),
                        ["-ai", environment["FIREBASE_GOOGLE_APP_ID"], "-p", "ios", str(dsym)],
                    )


if __name__ == "__main__":
    unittest.main()

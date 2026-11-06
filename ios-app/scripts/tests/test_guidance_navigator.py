"""Behavior checks for the explicit, non-buildable guidance inventory."""

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location(
    "navigator", Path(__file__).resolve().parents[1] / "sync-guidance-navigator.py"
)
navigator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(navigator)


class GuidanceNavigatorTests(unittest.TestCase):
    def test_inventory_excludes_local_files_and_alias_duplicates(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs").mkdir()
            for name in ("guide.md", "local.md"):
                (root / "docs" / name).write_text("guidance")
            (root / "docs/alias.md").symlink_to("guide.md")
            tracked = b"docs/guide.md\0docs/alias.md\0docs/deleted.md\0.env\0app.swift\0"
            with patch.object(navigator, "ROOT", root), patch.object(
                navigator.subprocess, "check_output", return_value=tracked
            ):
                self.assertEqual(navigator.guidance_files(), ["docs/guide.md"])

    def test_broken_alias_is_an_error(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "docs").mkdir()
            (root / "docs/alias").symlink_to("missing")
            with patch.object(navigator, "ROOT", root), patch.object(
                navigator.subprocess, "check_output", return_value=b"docs/alias\0"
            ), self.assertRaisesRegex(ValueError, "Broken guidance alias"):
                navigator.guidance_files()

    def test_refresh_preserves_surrounding_native_json_and_has_no_membership(self):
        old = json.dumps(navigator.guidance_group([]), indent=2)
        before = '{"files": [\n    '
        after = ',\n], "targets": [{"name": "App",}],}\n'
        source = before + old + after
        group = navigator.guidance_group(["AGENTS.md", "docs/guide.md"])
        updated = navigator.replacement(source, group)
        self.assertTrue(updated.startswith(before))
        self.assertTrue(updated.endswith(after))
        self.assertNotIn("target-membership", json.dumps(group))
        self.assertEqual(navigator.replacement(updated, group), updated)

    def test_missing_or_duplicate_managed_group_is_an_error(self):
        group = navigator.guidance_group([])
        for source in ("{}", json.dumps([group, group])):
            with self.assertRaisesRegex(ValueError, "exactly one"):
                navigator.replacement(source, group)


if __name__ == "__main__":
    unittest.main()

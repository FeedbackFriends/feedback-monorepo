import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
    "setup_xcode_plugin", Path(__file__).parents[1] / "setup-xcode-plugin.py"
)
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


class XcodePluginSetupTests(unittest.TestCase):
    def test_refresh_removes_stale_files_and_preserves_official_content(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            exports = root / "exports"
            for client in ("codex", "claude"):
                package = exports / client
                manifest = package / f".{client}-plugin/plugin.json"
                manifest.parent.mkdir(parents=True)
                manifest.write_text(json.dumps({"name": "xcode-integration"}))
                skill = package / "skills/device-interaction/SKILL.md"
                skill.parent.mkdir(parents=True)
                skill.write_text("Official instructions\n")

            def export(command, **kwargs):
                return subprocess.CompletedProcess(command, 0, str(exports / command[-1]) + "\n")

            with patch.object(setup.subprocess, "run", side_effect=export):
                setup.prepare(root)
                stale = root / ".agents/local-plugins/codex/stale.md"
                stale.write_text("old Xcode content")
                setup.prepare(root)
            self.assertFalse(stale.exists())
            for client in ("codex", "claude"):
                skill = root / f".agents/local-plugins/{client}/skills/device-interaction/SKILL.md"
                self.assertEqual(skill.read_text(), "Official instructions\n")

    def test_failed_export_preserves_existing_packages(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            marker = root / ".agents/local-plugins/codex/keep.md"
            marker.parent.mkdir(parents=True)
            marker.write_text("previous working package")
            with patch.object(setup.subprocess, "run", side_effect=subprocess.CalledProcessError(1, "xcrun")):
                with self.assertRaises(subprocess.CalledProcessError):
                    setup.prepare(root)
            self.assertEqual(marker.read_text(), "previous working package")


if __name__ == "__main__":
    unittest.main()

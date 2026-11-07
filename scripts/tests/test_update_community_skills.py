import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location(
    "community_updates", Path(__file__).resolve().parents[1] / "update-community-skills.py"
)
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)


class CommunitySkillUpdatesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.lock = self.root / "skills-lock.json"
        self.lock.write_text(json.dumps({"skills": {
            name: {"source": "owner/skills", "sourceType": "github", "computedHash": "old"}
            for name in ["first", "second"]
        }}))
        for name in ["first", "second", "lg-custom"]:
            skill = self.root / ".agents/skills" / name / "SKILL.md"
            skill.parent.mkdir(parents=True)
            skill.write_text(f"---\nname: {name}\ndescription: Example\n---\n")
        self.catalog = self.root / "docs/skills.md"
        self.catalog.parent.mkdir()
        self.catalog.write_text('**skills.sh updated at:** `2000-01-01T00:00:00Z`\n' + "\n".join(
            f"| [{name}](../.agents/skills/{name}/SKILL.md) | Example | "
            + (f"https://skills.sh/owner/skills/{name} |" if not name.startswith("lg-") else "")
            for name in ["first", "second", "lg-custom"]
        ))
        self.original = self.catalog.read_text()

    def install(self, command, **kwargs):
        self.assertEqual(command[:6], ["npx", "--yes", "skills@latest", "add", "owner/skills", "--skill"])
        self.assertEqual(command[6:8], ["first", "second"])
        self.assertNotIn("lg-custom", command)
        locked = json.loads(self.lock.read_text())
        for entry in locked["skills"].values():
            entry["computedHash"] = "fresh"
        self.lock.write_text(json.dumps(locked))
        return subprocess.CompletedProcess(command, 0, json.dumps([
            {"name": name, "status": "installed"} for name in ["first", "second"]
        ]), "")

    def test_full_success_refreshes_timestamp_and_keeps_custom_skill(self):
        custom = self.root / ".agents/skills/lg-custom/SKILL.md"
        original = custom.read_bytes()
        with patch.object(updater.subprocess, "run", side_effect=self.install) as run:
            updater.refresh(self.root)
        self.assertEqual(run.call_count, 1)
        self.assertNotIn("2000-01-01T00:00:00Z", self.catalog.read_text())
        self.assertEqual(custom.read_bytes(), original)
        self.assertEqual(self.original.splitlines()[1:], self.catalog.read_text().splitlines()[1:])

    def test_local_apple_content_is_excluded_from_community_inventory(self):
        apple = self.root / ".agents/skills/device-interaction"
        apple.mkdir()
        (apple / "SKILL.md").write_text("Apple guidance")
        (apple.parent / ".apple-skills.json").write_text('["device-interaction"]')
        with patch.object(updater.subprocess, "run", side_effect=self.install):
            updater.refresh(self.root)
        self.assertEqual((apple / "SKILL.md").read_text(), "Apple guidance")

    def test_skipped_install_does_not_advance_timestamp(self):
        result = subprocess.CompletedProcess([], 0, '[{"name":"first","status":"skipped"}]', "")
        with patch.object(updater.subprocess, "run", return_value=result):
            with self.assertRaisesRegex(ValueError, "did not refresh"):
                updater.refresh(self.root)
        self.assertEqual(self.catalog.read_text(), self.original)

    def test_failed_installer_does_not_advance_timestamp(self):
        with patch.object(updater.subprocess, "run", side_effect=subprocess.CalledProcessError(1, "npx")):
            with self.assertRaises(subprocess.CalledProcessError):
                updater.refresh(self.root)
        self.assertEqual(self.catalog.read_text(), self.original)

    def test_invalid_json_does_not_advance_timestamp(self):
        with patch.object(updater.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "oops", "")):
            with self.assertRaisesRegex(ValueError, "invalid JSON"):
                updater.refresh(self.root)
        self.assertEqual(self.catalog.read_text(), self.original)

    def test_catalog_mismatch_fails_before_installing(self):
        self.catalog.write_text(self.original.replace("| [first]", "| [wrong]"))
        with patch.object(updater.subprocess, "run") as run:
            with self.assertRaisesRegex(ValueError, "every installed skill"):
                updater.refresh(self.root)
            run.assert_not_called()

    def test_missing_installed_metadata_prevents_freshness(self):
        def install(command, **kwargs):
            result = self.install(command, **kwargs)
            (self.root / ".agents/skills/second/SKILL.md").unlink()
            return result
        with patch.object(updater.subprocess, "run", side_effect=install):
            with self.assertRaisesRegex(ValueError, "Missing or mismatched"):
                updater.refresh(self.root)
        self.assertEqual(self.catalog.read_text(), self.original)


if __name__ == "__main__":
    unittest.main()

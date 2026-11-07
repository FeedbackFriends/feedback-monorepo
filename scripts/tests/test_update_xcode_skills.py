import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('apple_updates', Path(__file__).parents[1] / 'update-xcode-skills.py')
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)


class AppleSkillUpdatesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.names = ['device-interaction', 'swiftui-specialist']

    def export(self, command, **kwargs):
        self.assertEqual(command[:6], ['xcrun', 'agent', 'skills', 'export', '--output-dir', command[5]])
        for name in self.names:
            folder = Path(command[5]) / name
            folder.mkdir(parents=True)
            (folder / 'SKILL.md').write_text(f'---\nname: {name}\ndescription: Example\n---\n')
            (folder / 'reference.md').write_text('Supporting content')

    def refresh(self):
        with patch.object(updater.subprocess, 'run', side_effect=self.export):
            updater.refresh(self.root)

    def test_refresh_updates_both_clients_and_removes_stale_aliases(self):
        self.refresh()
        for client in ['.agents', '.claude']:
            alias = self.root / client / 'skills/device-interaction'
            self.assertTrue(alias.is_symlink())
            self.assertEqual((alias / 'reference.md').read_text(), 'Supporting content')
        self.names = ['device-interaction']
        self.refresh()
        for client in ['.agents', '.claude']:
            self.assertFalse((self.root / client / 'skills/swiftui-specialist').is_symlink())
        self.assertEqual(json.loads((self.root / '.agents/apple-skills/.inventory.json').read_text()), self.names)

    def test_existing_directory_is_not_overwritten(self):
        self.refresh()
        unrelated = self.root / '.claude/skills/new-skill'
        unrelated.mkdir()
        self.names = ['new-skill']
        with self.assertRaises(FileExistsError):
            self.refresh()
        self.assertTrue(unrelated.is_dir())

    def test_failed_export_preserves_previous_content(self):
        self.refresh()
        with patch.object(updater.subprocess, 'run', side_effect=subprocess.CalledProcessError(1, 'xcrun')):
            with self.assertRaises(subprocess.CalledProcessError):
                updater.refresh(self.root)
        self.assertTrue((self.root / '.agents/skills/device-interaction/SKILL.md').exists())

    def test_unrelated_ignore_file_is_preserved(self):
        folder = self.root / '.agents/skills'
        folder.mkdir(parents=True)
        ignore = folder / '.gitignore'
        ignore.write_text('personal-rule\n')
        with self.assertRaisesRegex(ValueError, 'unrelated ignore file'):
            self.refresh()
        self.assertEqual(ignore.read_text(), 'personal-rule\n')

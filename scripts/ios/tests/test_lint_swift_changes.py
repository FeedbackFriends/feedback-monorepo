"""Exercise the lint gate against real Git changes and controlled SwiftLint output."""

import json
import os
from pathlib import Path
import subprocess
import shutil
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "lint-swift-changes.py"


class LintChangesTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.env = dict(os.environ, GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM="1")
        self.file = self.root / "ios-app/App/Example.swift"
        self.file.parent.mkdir(parents=True)
        self.file.write_text("let existing = 1\nlet unchanged = 2\n")
        (self.root / "ios-app/.swiftlint.yml").write_text("{}\n")
        self.git("init", "-q")
        self.git("add", ".")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "Base")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        fake = self.bin / "swiftlint"
        fake.write_text(f"#!{sys.executable}\nimport os\nprint(os.environ['LINT_REPORT'])\n"
                        "raise SystemExit(int(os.environ.get('LINT_STATUS', '0')))\n")
        fake.chmod(0o755)

    def git(self, *args):
        return subprocess.check_output(["git", *args], cwd=self.root, env=self.env, text=True)

    def violation(self, path, line):
        return dict(file=str(path), line=line, character=1, severity="Warning",
                    reason="Example violation", rule_id="example")

    def run_lint(self, report, status=0, base="HEAD"):
        env = dict(self.env, PATH=f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                   LINT_REPORT=report if isinstance(report, str) else json.dumps(report),
                   LINT_STATUS=str(status))
        return subprocess.run([sys.executable, str(SCRIPT), "--base", base], cwd=self.root,
                              env=env, text=True, capture_output=True)

    def test_untouched_violations_do_not_fail_or_modify_files(self):
        self.file.write_text("let existing = 1\nlet changed = 3\n")
        before = self.file.read_bytes()
        result = self.run_lint([self.violation(self.file, 1)], status=2)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, self.file.read_bytes())

    def test_changed_line_warning_fails(self):
        self.file.write_text("let existing = 1\nlet changed = 3\n")
        result = self.run_lint([self.violation(self.file, 2)])
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("ios-app/App/Example.swift:2:1: warning", result.stdout)

    def test_staged_and_unstaged_lines_are_checked_together(self):
        self.file.write_text("let staged = 3\nlet unchanged = 2\n")
        self.git("add", ".")
        self.file.write_text("let staged = 3\nlet unstaged = 4\n")
        result = self.run_lint([self.violation(self.file, 1), self.violation(self.file, 2)])
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("2 violation(s)", result.stdout)

    def test_untracked_file_with_spaces_is_checked(self):
        new = self.file.with_name("New File.swift")
        new.write_text("let added = 1\n")
        result = self.run_lint([self.violation(new, 1)])
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("New File.swift:1", result.stdout)

    def test_deleted_file_needs_no_lint(self):
        self.file.unlink()
        result = self.run_lint("invalid JSON")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("no changed Swift lines", result.stdout)

    def test_invalid_report_is_a_tooling_failure(self):
        self.file.write_text("let changed = 1\n")
        result = self.run_lint("invalid JSON")
        self.assertEqual(result.returncode, 2)
        self.assertIn("no usable JSON", result.stderr)

    def test_failed_tool_with_empty_report_is_not_clean(self):
        self.file.write_text("let changed = 1\n")
        self.assertEqual(self.run_lint([], status=1).returncode, 2)

    def test_invalid_base_fails_instead_of_skipping(self):
        self.assertEqual(self.run_lint([], base="missing-branch").returncode, 2)

    @unittest.skipUnless(shutil.which("swiftlint"), "SwiftLint is not installed")
    def test_real_swiftlint_respects_exclusions_and_changed_lines(self):
        (self.root / "ios-app/.swiftlint.yml").write_text(
            "only_rules:\n  - force_try\nexcluded:\n  - Modules/Tests\n"
            "  - Modules/Sources/OpenAPI/GeneratedSources\n"
        )
        self.file.write_text("let existing = try! work()\nlet unchanged = 2\n")
        self.git("add", ".")
        self.git("-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "Legacy lint")
        self.file.write_text("let existing = try! work()\nlet changed = 3\n")
        for relative in ["Modules/Tests/Test.swift", "Modules/Sources/OpenAPI/GeneratedSources/Types.swift"]:
            excluded = self.root / "ios-app" / relative
            excluded.parent.mkdir(parents=True, exist_ok=True)
            excluded.write_text("let excluded = try! work()\n")

        def real_lint():
            return subprocess.run([sys.executable, str(SCRIPT), "--base", "HEAD"],
                                  cwd=self.root, env=self.env, text=True, capture_output=True)

        before = self.file.read_bytes()
        result = real_lint()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), before)
        self.file.write_text("let existing = try! work()\nlet changed = try! work()\n")
        result = real_lint()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Example.swift:2:", result.stdout)


if __name__ == "__main__":
    unittest.main()

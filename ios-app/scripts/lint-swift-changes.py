#!/usr/bin/env python3
"""Gate SwiftLint violations on changed lines without modifying the checkout."""

import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys


def git(*args):
    return subprocess.check_output(["git", *args], text=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="Merge-base SHA or HEAD for uncommitted work")
    args = parser.parse_args()
    root = Path(git("rev-parse", "--show-toplevel").strip()).resolve()
    # Resolve to a commit before passing the base to diff, including for option-like input.
    base = git("rev-parse", "--verify", "--end-of-options", f"{args.base}^{{commit}}").strip()
    paths = git("-C", str(root), "diff", "--name-only", "-z", "--no-renames",
                "--diff-filter=AM", base, "--", "ios-app/**/*.swift").split("\0")
    untracked = git("-C", str(root), "ls-files", "--others", "--exclude-standard",
                    "-z", "--", "ios-app/**/*.swift").split("\0")
    changed = {}
    for path in sorted(set(paths + untracked) - {""}):
        if not (root / path).is_file():
            continue
        if path in untracked:
            changed[path] = set(range(1, len((root / path).read_text().splitlines()) + 1))
            continue
        diff = git("-C", str(root), "diff", "--no-ext-diff", "--no-textconv",
                   "--no-renames", "-U0", base, "--", path)
        lines = set()
        for start, count in re.findall(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@", diff, re.M):
            lines.update(range(int(start), int(start) + int(count or 1)))
        if lines:
            changed[path] = lines
    if not changed:
        print("SwiftLint: no changed Swift lines.")
        return 0
    if not shutil.which("swiftlint"):
        raise RuntimeError("swiftlint is required (brew install swiftlint)")
    # Lint the configured scope once so SwiftLint itself owns includes/excludes.
    # Passing excluded files individually makes SwiftLint exit with no JSON report.
    result = subprocess.run(
        ["swiftlint", "lint", "--quiet", "--config", ".swiftlint.yml", "--reporter", "json"],
        cwd=root / "ios-app", text=True, capture_output=True,
    )
    try:
        report = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"SwiftLint produced no usable JSON: {result.stderr.strip()}") from error
    if not isinstance(report, list) or result.returncode not in (0, 1, 2):
        raise RuntimeError(f"SwiftLint failed: {result.stderr.strip()}")
    if result.returncode and not report:
        raise RuntimeError(f"SwiftLint failed without violations: {result.stderr.strip()}")
    violations = 0
    for violation in report:
        file = Path(violation["file"])
        if not file.is_absolute():
            file = root / "ios-app" / file
        path = file.resolve().relative_to(root).as_posix()
        if violation["line"] in changed.get(path, set()):
            violations += 1
            print(f"{path}:{violation['line']}:{violation.get('character') or 1}: "
                  f"{violation['severity'].lower()}: {violation['reason']} ({violation['rule_id']})")
    print(f"SwiftLint: {violations} violation(s) on changed lines in {len(changed)} file(s).")
    return int(violations > 0)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, subprocess.CalledProcessError, RuntimeError, KeyError, TypeError, ValueError) as error:
        print(f"SwiftLint check failed: {error}", file=sys.stderr)
        sys.exit(2)

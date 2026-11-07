#!/usr/bin/env python3
"""Refresh the non-buildable Repository guidance group from Git's file inventory."""

import argparse
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[2]
PROJECT = ROOT / "ios-app/Feedback.xcodeproj/project.xcproj"
GROUP_NAME = "Repository guidance"
DIRECTORIES = (
    ".agents/", ".codex/", "docs/", "tasks/",
    "ios-app/.agents/", "ios-app/Docs/",
    "backend/.agents/", "backend/docs/",
    "web/.agents/", "web/docs/",
)
SKILL_DIRECTORIES = tuple(
    f"{prefix}.agents/skills/" for prefix in ("", "ios-app/", "backend/", "web/")
)
FILES = {
    f"{prefix}{name}"
    for prefix in ("", "ios-app/", "backend/", "web/")
    for name in ("AGENTS.md", "README.md")
}


def guidance_files():
    # Deliberately exclude untracked/ignored local files, even inside these roots.
    tracked = subprocess.check_output(
        ["git", "ls-files", "-z"], cwd=ROOT
    ).decode().split("\0")
    result = []
    for name in sorted(set(tracked)):
        if name not in FILES and not name.startswith(DIRECTORIES):
            continue
        if any(
            name.startswith(prefix) and not name[len(prefix):].split("/", 1)[0].startswith("lg-")
            for prefix in SKILL_DIRECTORIES
        ):
            continue
        path = ROOT / name
        if path.is_symlink():
            if not path.exists():
                raise ValueError(f"Broken guidance alias: {name}")
            # Canonical content is exposed at its real location, once.
            continue
        if path.is_file():
            result.append(name)
    return result


def guidance_group(paths):
    tree = {}
    for path in paths:
        node = tree
        parts = path.split("/")
        for part in parts[:-1]:
            node = node.setdefault(part, {})
        node[parts[-1]] = None

    def children(node):
        return [
            {"kind": "group", "path": name, "children": children(value)}
            if value is not None else {"path": name}
            for name, value in sorted(node.items())
        ]

    # No target-membership on groups or leaves: navigator visibility only.
    return {
        "kind": "group", "name": GROUP_NAME,
        "path": "<PROJECT>/..", "children": children(tree),
    }


def replacement(source, group):
    # Only this generated group uses strict JSON. Preserve the surrounding native
    # JSON (including trailing commas) and all build configuration byte for byte.
    marker = f'"name": "{GROUP_NAME}"'
    if source.count(marker) != 1:
        raise ValueError("Expected exactly one Repository guidance group")
    start = source.rfind("{", 0, source.index(marker))
    _, length = json.JSONDecoder().raw_decode(source[start:])
    encoded = json.dumps(group, indent=2, ensure_ascii=False)
    encoded = encoded.replace("\n", "\n    ")
    return source[:start] + encoded + source[start + length:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if a refresh is needed")
    args = parser.parse_args()
    paths = guidance_files()
    source = PROJECT.read_text()
    updated = replacement(source, guidance_group(paths))
    if args.check and source != updated:
        parser.exit(1, "Guidance navigator is stale; run this script without --check.\n")
    if not args.check:
        PROJECT.write_text(updated)
    print(f"Guidance navigator {'checked' if args.check else 'refreshed'}: {len(paths)} files")


if __name__ == "__main__":
    main()

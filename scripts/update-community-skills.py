#!/usr/bin/env python3
"""Refresh all locked community skills; record freshness only after full success."""

from collections import defaultdict
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]


def refresh(root=ROOT):
    lock_path = root / "skills-lock.json"
    locked = json.loads(lock_path.read_text())["skills"]
    if not locked or any(name.startswith("lg-") for name in locked):
        raise ValueError("Lockfile must contain community skills only")

    catalog_path = root / "docs/skills.md"
    catalog = catalog_path.read_text()
    listed = re.findall(r"^\| \[([^]]+)\]\(\.\./\.agents/skills/[^)]+\)", catalog, re.M)
    skills = root / ".agents/skills"
    manifest = skills / ".apple-skills.json"
    apple = set(json.loads(manifest.read_text())) if manifest.exists() else set()
    installed = {path.parent.name for path in skills.glob("*/SKILL.md")} - apple
    if len(listed) != len(set(listed)) or set(listed) != installed:
        raise ValueError("Skills overview must list every installed skill exactly once")
    if installed - {name for name in installed if name.startswith("lg-")} != set(locked):
        raise ValueError("Community inventory and lockfile disagree")
    stamp_pattern = r"(?m)^\*\*skills\.sh updated at:\*\* `[^`]+`$"
    if len(re.findall(stamp_pattern, catalog)) != 1:
        raise ValueError("Expected one community freshness timestamp")

    sources = defaultdict(list)
    for name, entry in locked.items():
        if entry["sourceType"] != "github":
            raise ValueError(f"Unsupported source type for {name}")
        sources[entry["source"]].append(name)

    # Refresh explicit names: `skills update` can silently skip nested upstream skills.
    for source, names in sorted(sources.items()):
        print(f"Refreshing {source}: {', '.join(sorted(names))}", flush=True)
        result = subprocess.run(
            ["npx", "--yes", "skills@latest", "add", source, "--skill", *sorted(names),
             "--agent", "codex", "--yes", "--json"],
            cwd=root, capture_output=True, text=True, check=True,
        )
        try:
            outcomes = json.loads(result.stdout)
        except json.JSONDecodeError as error:
            raise ValueError(f"Installer returned invalid JSON for {source}") from error
        if not isinstance(outcomes, list) or len(outcomes) != len(names) or {
            item.get("name") for item in outcomes if item.get("status") == "installed"
        } != set(names):
            raise ValueError(f"Installer did not refresh every selected skill: {outcomes}")

    updated = json.loads(lock_path.read_text())["skills"]
    if set(updated) != set(locked):
        raise ValueError("Installer changed the community inventory")
    for name, entry in updated.items():
        if entry["source"] != locked[name]["source"] or entry["sourceType"] != "github":
            raise ValueError(f"Installer changed source ownership for {name}")
        skill = root / ".agents/skills" / name / "SKILL.md"
        if not skill.is_file() or not re.search(
            rf"(?m)^name:\s*{re.escape(name)}\s*$", skill.read_text()
        ):
            raise ValueError(f"Missing or mismatched installed skill: {name}")
        url = f"https://skills.sh/{entry['source']}/{name}"
        if url not in catalog:
            raise ValueError(f"Missing source link in overview: {name}")

    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    catalog_path.write_text(re.sub(stamp_pattern, f"**skills.sh updated at:** `{timestamp}`", catalog))
    print(f"Refreshed {len(updated)} community skills at {timestamp}")


if __name__ == "__main__":
    refresh()

#!/usr/bin/env python3
"""Prepare ignored, client-specific copies of the selected Xcode's plugin."""

import json
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def prepare(root=ROOT):
    destination = root / ".agents/local-plugins"
    destination.mkdir(parents=True, exist_ok=True)
    # Validate both exports before replacing either local package.
    with tempfile.TemporaryDirectory(prefix="xcode-", dir=destination) as temporary:
        staged = Path(temporary)
        for client in ("codex", "claude"):
            result = subprocess.run(
                ["xcrun", "agent", "plugin", "path", "--plugin-format", client],
                check=True, capture_output=True, text=True,
            )
            source = Path(result.stdout.strip())
            manifest = source / f".{client}-plugin/plugin.json"
            if not source.is_absolute() or json.loads(manifest.read_text()).get("name") != "xcode-integration":
                raise ValueError(f"Unexpected {client} plugin export: {source}")
            if not (source / "skills/device-interaction/SKILL.md").is_file():
                raise ValueError(f"Missing device-interaction skill: {source}")
            shutil.copytree(source, staged / client)

        for client in ("codex", "claude"):
            target = destination / client
            if target.is_symlink():
                target.unlink()
            elif target.exists():
                shutil.rmtree(target)
            shutil.move(str(staged / client), target)
            print(f"Prepared {client}: {target}")


if __name__ == "__main__":
    try:
        prepare()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        detail = error.stderr if isinstance(error, subprocess.CalledProcessError) else str(error)
        raise SystemExit(f"Xcode plugin setup failed: {detail or error}") from error
    print("Next: follow ios-app/Docs/agent-harness.md#apple-plugin-setup for client installation.")

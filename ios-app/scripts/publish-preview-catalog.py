#!/usr/bin/env python3
"""Validate native Xcode RenderPreview results and publish original-size PNG files.

Rendering is performed through native Xcode MCP, not this filesystem-only publisher.
"""
import argparse
import json
from pathlib import Path
import re
import shutil
import struct
import zlib

APP_ROOT = Path(__file__).resolve().parents[1]
REGISTRY = APP_ROOT / "preview-catalog.json"


def load_registry(root=APP_ROOT):
    """Discover named previews; Swift owns IDs and order, JSON owns render settings only.

    Dedicated catalog files use one-line #Preview("stable.id") declarations. Fail on
    unsupported declarations rather than silently shifting Xcode's positional indexes.
    """
    registry = json.loads((root / "preview-catalog.json").read_text())
    screens = []
    for source in sorted((root / "Modules/Sources").glob("*/ScreenCatalogPreviewView.swift")):
        index = 0
        for number, line in enumerate(source.read_text().splitlines(), 1):
            if not line.lstrip().startswith("#Preview"):
                continue
            match = re.fullmatch(r'\s*#Preview\("([a-z0-9]+(?:[.-][a-z0-9]+)*)"(?:, traits: \.fixedLayout\(width: \d+, height: \d+\))?\) \{(?: \w+\([^{}]*\) \})?\s*', line)
            if not match:
                raise ValueError(f"Use a named, one-line catalog preview: {source}:{number}")
            identifier = match[1]
            screens.append({"id": identifier, "title": identifier.replace(".", " · ").replace("-", " "),
                            "previewIndex": index, "source": str(source.relative_to(root)), "line": number})
            index += 1
    ids = [screen["id"] for screen in screens]
    if not ids or len(ids) != len(set(ids)):
        raise ValueError("Catalog previews must have unique stable IDs and include at least one state")
    registry["screens"] = screens
    return registry


def png_size(data):
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("Not a PNG")
    offset, size, has_pixels = 8, None, False
    while offset + 12 <= len(data):
        length = struct.unpack(">I", data[offset:offset + 4])[0]
        kind = data[offset + 4:offset + 8]
        end = offset + 8 + length
        if end + 4 > len(data):
            raise ValueError("Truncated PNG")
        payload = data[offset + 8:end]
        crc = struct.unpack(">I", data[end:end + 4])[0]
        if zlib.crc32(kind + payload) & 0xFFFFFFFF != crc:
            raise ValueError("PNG checksum mismatch")
        if kind == b"IHDR":
            size = struct.unpack(">II", payload[:8])
        if kind == b"IDAT":
            has_pixels = True
        if kind == b"IEND":
            if not size or min(size) < 200 or not has_pixels:
                raise ValueError("Missing or unexpectedly small PNG content")
            return size
        offset = end + 4
    raise ValueError("Incomplete PNG")


def plan(registry):
    return [{"id": screen["id"], "arguments": {
        "sourceFilePath": screen["source"],
        "previewDefinitionIndexInFile": screen["previewIndex"], "timeout": 60
    }} for screen in registry["screens"]]


def publish(registry, captures, destination):
    expected = registry["screens"]
    ids = [screen["id"] for screen in expected]
    if not ids or len(ids) != len(set(ids)):
        raise ValueError("Catalog preview IDs must be unique")
    if len(captures) != len(expected) or {capture["id"] for capture in captures} != set(ids):
        raise ValueError("A successful capture of every registered preview is required")

    by_id = {capture["id"]: capture for capture in captures}
    entries = []
    environment = None
    for screen in expected:
        capture = by_id[screen["id"]]
        result = capture["result"]
        if result.get("errors") or result.get("displayName") != screen["id"]:
            raise ValueError(f"Failed or wrong preview: {screen['id']}")
        source = Path(result["previewSnapshotPath"])
        size = png_size(source.read_bytes())
        device = result["renderedDestination"]
        current_environment = (device["deviceModelName"], device["systemVersion"])
        if environment is not None and environment != current_environment:
            raise ValueError("Capture device or runtime changed during the batch")
        environment = current_environment
        entries.append({"id": screen["id"], "file": f"{screen['id']}.png",
                        "width": size[0], "height": size[1], "source": source})

    # Validate every image before replacing any files in the output folder.
    destination.mkdir(parents=True, exist_ok=True)
    names = {entry["file"] for entry in entries}
    for old_file in destination.glob("*.png"):
        if old_file.name not in names:
            old_file.unlink()
    for helper in ("index.html", "README.md", "manifest.json", "repeat-check.json", "concurrency-check.json"):
        (destination / helper).unlink(missing_ok=True)
    for entry in entries:
        shutil.copyfile(entry["source"], destination / entry["file"])
    return entries

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", action="store_true", help="Print native RenderPreview arguments; does not render")
    parser.add_argument("--captures", type=Path, help="JSON array of {id, seconds, result: native structuredContent}")
    args = parser.parse_args()
    registry = load_registry()
    if args.plan:
        print(json.dumps(plan(registry), indent=2))
        return
    if not args.captures:
        parser.error("Supply --captures or --plan")
    entries = publish(registry, json.loads(args.captures.read_text()), APP_ROOT / "Docs/screenshots/catalog")
    print(f"Published {len(entries)} full-size PNG screenshots to Docs/screenshots/catalog")


if __name__ == "__main__":
    main()

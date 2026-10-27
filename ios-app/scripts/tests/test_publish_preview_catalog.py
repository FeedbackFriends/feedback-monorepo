import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import unittest
import zlib

spec = importlib.util.spec_from_file_location("publisher", Path(__file__).parents[1] / "publish-preview-catalog.py")
publisher = importlib.util.module_from_spec(spec)
spec.loader.exec_module(publisher)


def png():
    def chunk(kind, payload):
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload))
    return (b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", 200, 400, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress((b"\0" + b"\xff" * 800) * 400)) + chunk(b"IEND", b""))


class PublisherTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "capture.png"
        self.source.write_bytes(png())
        self.destination = self.root / "gallery"
        self.registry = {"renderer": "Xcode RenderPreview", "scheme": "Localhost", "fixture": {},
                         "sourceFilePath": "Fixture.swift", "screens": [{"id": "home.empty", "title": "Home", "previewIndex": 0, "source": "Fixture.swift"}]}
        self.capture = {"id": "home.empty", "seconds": 0.5, "result": {
            "displayName": "home.empty", "previewSnapshotPath": str(self.source), "errors": [],
            "renderedDestination": {"deviceModelName": "Test iPhone", "systemVersion": "27.2"}}}

    def test_failed_batch_preserves_last_successful_gallery(self):
        publisher.publish(self.registry, [self.capture], self.destination)
        previous = (self.destination / "home.empty.png").read_bytes()
        with self.assertRaises(ValueError):
            publisher.publish(self.registry, [], self.destination)
        self.assertEqual(previous, (self.destination / "home.empty.png").read_bytes())

    def test_wrong_preview_is_rejected_before_publication(self):
        self.capture["result"]["displayName"] = "another.screen"
        with self.assertRaises(ValueError):
            publisher.publish(self.registry, [self.capture], self.destination)
        self.assertFalse(self.destination.exists())

    def test_corrupt_png_is_rejected_before_publication(self):
        self.source.write_bytes(self.source.read_bytes()[:-4])
        with self.assertRaises(ValueError):
            publisher.publish(self.registry, [self.capture], self.destination)
        self.assertFalse(self.destination.exists())

    def test_repeated_identical_export_is_marked_unchanged(self):
        publisher.publish(self.registry, [self.capture], self.destination)
        result = publisher.publish(self.registry, [self.capture], self.destination)
        self.assertEqual("home.empty", result[0]["id"])
        self.assertEqual(self.source.read_bytes(), (self.destination / "home.empty.png").read_bytes())


if __name__ == "__main__":
    unittest.main()

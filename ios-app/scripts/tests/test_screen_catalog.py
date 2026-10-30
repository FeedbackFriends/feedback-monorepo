import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

from PIL import Image

spec = importlib.util.spec_from_file_location('catalog', Path(__file__).parents[1] / 'screen-catalog.py')
catalog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(catalog)


class CatalogTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / 'Modules/Sources/TestFeature/ScreenCatalogPreviewView.swift'
        self.source.parent.mkdir(parents=True)
        self.source.write_text('#if DEBUG\n// Screenshot: Test layout.\n#Preview("home.empty") { sampleView() }\n#endif\n')
        (self.root / 'screen-catalog.json').write_text(json.dumps({}))

    def test_generation_reuses_preview_body_and_is_idempotent(self):
        registry = catalog.load_registry(self.root)
        catalog.generate(registry, self.root)
        expected = self.source.read_text()
        self.assertIn('.init(id: "home.empty", size: CGSize(width: 402, height: 874))', expected)
        self.assertIn('sampleView()', expected)
        self.assertEqual(catalog.generate(catalog.load_registry(self.root), self.root, check=True), [])
        self.assertEqual(expected, self.source.read_text())
        self.source.write_text(expected.replace('sampleView()', 'changedView()', 1))
        with self.assertRaisesRegex(ValueError, 'Regenerate'):
            catalog.generate(catalog.load_registry(self.root), self.root, check=True)

    def test_unmarked_previews_stay_out_of_capture_and_generated_factories(self):
        self.source.write_text(
            '#if DEBUG\n// Screenshot: Main layout.\n#Preview("home.ready") { ready() }\n'
            '#Preview("home.loading") { loading() }\n#endif\n')
        registry = catalog.load_registry(self.root)
        self.assertEqual([screen['id'] for screen in registry['screens']], ['home.ready'])
        catalog.generate(registry, self.root)
        generated = self.source.read_text().split(catalog.START)[1]
        self.assertNotIn('home.loading', generated)
        self.assertIn('#Preview("home.loading")', self.source.read_text())

    def test_deselecting_last_preview_clears_module_factory(self):
        catalog.generate(catalog.load_registry(self.root), self.root)
        other = self.root / 'Modules/Sources/OtherFeature/ScreenCatalogPreviewView.swift'
        other.parent.mkdir(parents=True)
        other.write_text('#if DEBUG\n// Screenshot: Other screen.\n#Preview("other.ready") { other() }\n#endif\n')
        self.source.write_text(self.source.read_text().replace('// Screenshot: Test layout.\n', ''))
        registry = catalog.load_registry(self.root)
        catalog.generate(registry, self.root)
        self.assertNotIn('home.empty', self.source.read_text().split(catalog.START)[1])
        self.assertEqual(catalog.generate(catalog.load_registry(self.root), self.root, check=True), [])

    def test_body_parser_ignores_string_and_comment_braces(self):
        body = ' VStack { Text("}") // }\n Text("{") /* } */ } } trailing'
        self.assertEqual(catalog.preview_body(body, 0), 'VStack { Text("}") // }\nText("{") /* } */ }')

    def test_duplicate_ids_fail(self):
        self.source.write_text('#if DEBUG\n// Screenshot: Test layout.\n#Preview("home.empty") { a() }\n// Screenshot: Test layout.\n#Preview("home.empty") { b() }\n#endif')
        with self.assertRaisesRegex(ValueError, 'unique'):
            catalog.load_registry(self.root)
    def test_full_content_dimensions_and_alert_inclusion(self):
        self.source.write_text('#if DEBUG\n// Screenshot: Test layout.\n#Preview("home.full-content", traits: .fixedLayout(width: 402, height: 1700)) { a() }\n// Screenshot: Test layout.\n#Preview("system.alert") { b() }\n#endif')
        registry = catalog.load_registry(self.root)
        self.assertEqual(registry['screens'][0]['height'], 1700)
        catalog.generate(registry, self.root)
        generated = self.source.read_text().split(catalog.START)[1]
        self.assertIn('height: 1700', generated)
        self.assertIn('system.alert', generated)

    def test_invalid_or_failed_batch_preserves_previous_publication(self):
        registry = catalog.load_registry(self.root)
        captures, destination = self.root / 'captures', self.root / 'current'
        captures.mkdir()
        manifest = {'renderer': 'Point-Free SnapshotTesting', 'ids': ['home.empty'], 'failures': []}
        (captures / 'manifest.json').write_text(json.dumps(manifest))
        Image.new('RGBA', (1206, 2622), 'white').save(captures / 'home.empty.png')
        self.assertEqual(catalog.publish(registry, captures, destination), 1)
        previous = (destination / 'home.empty.png').read_bytes()
        manifest['failures'] = ['home.empty']
        (captures / 'manifest.json').write_text(json.dumps(manifest))
        with self.assertRaisesRegex(ValueError, 'failed'):
            catalog.publish(registry, captures, destination)
        self.assertEqual(previous, (destination / 'home.empty.png').read_bytes())
        manifest['failures'] = []
        (captures / 'manifest.json').write_text(json.dumps(manifest))
        Image.new('RGBA', (300, 500), 'white').save(captures / 'home.empty.png')
        with self.assertRaisesRegex(ValueError, 'dimensions'):
            catalog.publish(registry, captures, destination)
        self.assertEqual(previous, (destination / 'home.empty.png').read_bytes())

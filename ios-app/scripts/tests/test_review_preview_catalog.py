import importlib.util
from pathlib import Path
import tempfile
import unittest

from PIL import Image, PngImagePlugin

spec = importlib.util.spec_from_file_location('reviewer', Path(__file__).parents[1] / 'review-preview-catalog.py')
reviewer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reviewer)


class ReviewTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.before, self.after, self.report = [self.root / name for name in ('baseline', 'current', 'review')]
        self.before.mkdir()
        self.after.mkdir()

    def image(self, folder, name='home.empty', color='white', size=(200, 400)):
        path = folder / f'{name}.png'
        Image.new('RGBA', size, color).save(path)
        return path

    def review(self):
        return reviewer.review(self.before, self.after, self.report)

    def test_visual_gallery_includes_identical_screens_without_pixel_classification(self):
        from unittest.mock import patch
        self.image(self.before)
        self.image(self.after)
        with patch.object(reviewer, 'compare', side_effect=AssertionError('No pixel gate')):
            summary = reviewer.review(self.before, self.after, self.report, pixel_comparison=False)
        self.assertEqual(summary, {'added': 0, 'removed': 0, 'needs-review': 1})
        self.assertTrue((self.report / 'after/home.empty.png').exists())
        page = (self.report / 'index.html').read_text()
        self.assertIn('grid-template-columns:repeat(auto-fill', page)
        self.assertNotIn('src="before/', page)
        self.assertNotIn('<figcaption>After</figcaption>', page)
        self.assertNotIn('needs-review', page)
        reviewer.accept(self.report, identifiers=['home.empty'])

    def test_metadata_and_compression_do_not_count_as_visual_changes(self):
        old = self.image(self.before)
        info = PngImagePlugin.PngInfo()
        info.add_text('note', 'different encoder metadata')
        with Image.open(old) as img:
            img.save(self.after / old.name, pnginfo=info, compress_level=0)
        self.assertNotEqual(old.read_bytes(), (self.after / old.name).read_bytes())
        self.assertEqual(self.review(), {'changed': 0, 'added': 0, 'removed': 0, 'unchanged': 1})

    def test_rgb_change_with_equal_alpha_is_detected(self):
        old = self.image(self.before)
        new = self.image(self.after)
        with Image.open(new) as img:
            img.putpixel((5, 5), (0, 0, 0, 255))
            img.save(new)
        self.assertEqual(self.review()['changed'], 1)
        self.assertTrue((self.report / 'diff' / old.name).exists())
        self.assertIn('Compare with slider', (self.report / 'index.html').read_text())
        self.assertEqual(Image.open(old).getpixel((5, 5)), (255, 255, 255, 255))

    def test_alpha_only_change_is_detected(self):
        self.image(self.before, color=(255, 255, 255, 0))
        self.image(self.after)
        self.assertEqual(self.review()['changed'], 1)

    def test_dimension_change_has_no_slider(self):
        self.image(self.before)
        self.image(self.after, size=(200, 500))
        self.assertEqual(self.review()['changed'], 1)
        self.assertNotIn('Compare with slider', (self.report / 'index.html').read_text())

    def test_added_removed_and_selective_acceptance(self):
        removed = self.image(self.before, name='old.screen')
        self.image(self.after, name='new.screen')
        self.assertEqual(self.review(), {'changed': 0, 'added': 1, 'removed': 1, 'unchanged': 0})
        reviewer.accept(self.report, identifiers=['new.screen'])
        self.assertTrue((self.before / 'new.screen.png').exists())
        self.assertTrue(removed.exists())
        reviewer.accept(self.report, identifiers=['old.screen'])
        self.assertFalse(removed.exists())

    def test_acceptance_copies_reviewed_image_even_if_current_is_recaptured(self):
        self.image(self.before)
        new = self.image(self.after, color='black')
        self.review()
        reviewed = new.read_bytes()
        self.image(self.after, color='red')
        reviewer.accept(self.report, all_changes=True)
        self.assertEqual((self.before / new.name).read_bytes(), reviewed)

    def test_stale_baseline_rejects_whole_approval(self):
        self.image(self.before)
        self.image(self.after, color='black')
        self.image(self.after, name='added.screen')
        self.review()
        self.image(self.before, color='red')
        with self.assertRaisesRegex(ValueError, 'Baseline changed'):
            reviewer.accept(self.report, all_changes=True)
        self.assertFalse((self.before / 'added.screen.png').exists())

    def test_modified_review_image_rejects_approval(self):
        self.image(self.before)
        self.image(self.after, color='black')
        self.review()
        self.image(self.report / 'after', color='red')
        with self.assertRaisesRegex(ValueError, 'Review image changed'):
            reviewer.accept(self.report, all_changes=True)

    def test_repeat_check_requires_identical_pixels_and_cannot_be_accepted(self):
        self.image(self.before)
        self.image(self.after)
        self.assertEqual(reviewer.check_repeat(self.before, self.after, self.report)['changed'], 0)
        self.image(self.after, color='black')
        self.assertEqual(reviewer.check_repeat(self.before, self.after, self.report)['changed'], 1)
        with self.assertRaisesRegex(ValueError, 'Repeat checks cannot be accepted'):
            reviewer.accept(self.report, all_changes=True)

    def test_repeat_check_rejects_incomplete_or_empty_sets(self):
        with self.assertRaisesRegex(ValueError, 'same nonempty set'):
            reviewer.check_repeat(self.before, self.after, self.report)
        self.image(self.after)
        with self.assertRaisesRegex(ValueError, 'same nonempty set'):
            reviewer.check_repeat(self.before, self.after, self.report)

    def test_manual_system_state_is_not_reported_as_removed(self):
        self.image(self.before)
        self.image(self.after)
        self.image(self.before, name='system.alert')
        summary = reviewer.review(self.before, self.after, self.report, excluded=['system.alert'])
        self.assertEqual(summary['removed'], 0)
        self.assertEqual(summary['unchanged'], 1)
        self.assertEqual(summary['manualReview'], 1)
        self.assertTrue((self.before / 'system.alert.png').exists())

    def test_empty_capture_and_unknown_approval_fail(self):
        with self.assertRaisesRegex(ValueError, 'No current captures'):
            self.review()
        self.image(self.after)
        self.review()
        with self.assertRaisesRegex(ValueError, 'Choose screen IDs'):
            reviewer.accept(self.report, identifiers=['unknown.screen'])


if __name__ == '__main__':
    unittest.main()

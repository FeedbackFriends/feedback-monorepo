import importlib.util
from pathlib import Path
import tempfile
import unittest


SPEC = importlib.util.spec_from_file_location(
    'localized_copy', Path(__file__).resolve().parents[1] / 'check-unlocalized-copy.py'
)
guard = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(guard)


class LocalizedCopyTests(unittest.TestCase):
    def test_detects_english_danish_multiline_and_accessibility_copy(self):
        source = '''Button("Save") {}\nText("Gem")
        .accessibilityHint(
            "Open the session"
        )
        Text("""First line
        Second line""")'''
        self.assertEqual(list(guard.literals(source)), [
            (1, 'Save'), (2, 'Gem'), (4, 'Open the session'),
            (6, 'First line\n        Second line'),
        ])

    def test_ignores_comments_diagnostics_user_values_and_generated_accessors(self):
        source = r'''
        // Text("Comment")
        /* Button("Comment") {} */
        logger.debug("Text(\"diagnostic\")")
        Text(user.title)
        Text("\(user.title)")
        Text("10")
        Text("")
        Text(appStrings: .commonSave)
        Button(String(appStrings: .commonSave)) {}
        '''
        self.assertEqual(list(guard.literals(source)), [])

    def test_prose_around_interpolation_is_not_exempt(self):
        source = r'Text("You have \(count) responses")'
        self.assertEqual(list(guard.literals(source)), [(1, r'You have \(count) responses')])

    def test_verbatim_and_additional_presentation_apis_are_checked(self):
        for call in ['Text(verbatim: ', 'Toggle(', 'Picker(', 'DatePicker(',
                     'Menu(', 'Link(', 'ShareLink(', 'LabeledContent(',
                     'ContentUnavailableView(', 'ProgressView(',
                     '.navigationSubtitle(', '.accessibilityValue(', '.help(']:
            with self.subTest(call=call):
                self.assertEqual(list(guard.literals(call + '"Visible copy")')),
                                 [(1, 'Visible copy')])

    def test_comments_between_call_and_literal_are_ignored(self):
        self.assertEqual(list(guard.literals('Text(/* context */ "Gem")')), [(1, 'Gem')])

    def test_reviewed_exception_does_not_allow_new_copies_or_other_files(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            relative = 'Modules/Sources/DesignSystem/ReusableViews/LetsGrowFeedbackLogoView.swift'
            path = root / relative
            path.parent.mkdir(parents=True)
            path.write_text('Text("Lets Grow")\nText("Lets Grow")')
            other = root / 'App/Example.swift'
            other.parent.mkdir()
            other.write_text('Text("Lets Grow")')
            scanned, failures = guard.check(root, {relative: ('Brand lockup', {'Lets Grow': 1})})
        self.assertEqual(scanned, 2)
        self.assertEqual(len(failures), 2)
        self.assertTrue(any('Example.swift:1:' in error for error in failures))
        self.assertTrue(any('LogoView.swift:2:' in error for error in failures))

    def test_unused_or_missing_file_exceptions_fail(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / 'App/Example.swift'
            path.parent.mkdir()
            path.write_text('Text(user.title)')
            _, failures = guard.check(root, {
                'App/Example.swift': ('Removed sample', {'Sample': 1}),
                'App/Missing.swift': ('Removed file', {'Sample': 1}),
            })
        self.assertEqual(len(failures), 2)
        self.assertTrue(all('stale localization exception' in error for error in failures))

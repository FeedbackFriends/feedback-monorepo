import copy
import importlib.util
import json
from pathlib import Path
import plistlib
import tempfile
import unittest


SPEC = importlib.util.spec_from_file_location("validate_localization", Path(__file__).resolve().parents[1] / "validate-localization.py")
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class CatalogValidationTests(unittest.TestCase):
    def setUp(self):
        self.catalog = {
            "sourceLanguage": "da",
            "strings": {"example": {
                "comment": "A count and a verbatim user title.",
                "localizations": {"da": {"stringUnit": {"state": "translated", "value": "%1$lld: %2$@"}}},
            }},
        }

    def test_reordering_and_percent_literal_are_valid(self):
        self.catalog["strings"]["example"]["localizations"]["da"]["stringUnit"]["value"] = "%2$@: %1$lld (100%%)"
        self.assertEqual(validator.validate(self.catalog), [])

    def test_empty_catalog_is_rejected(self):
        self.catalog["strings"] = {}
        self.assertTrue(validator.validate(self.catalog))

    def test_missing_language_is_rejected(self):
        entry = copy.deepcopy(self.catalog["strings"]["example"])
        entry["localizations"]["fr"] = entry["localizations"]["da"]
        self.catalog["strings"]["second"] = entry
        self.assertTrue(any("example/fr: missing translation" in e for e in validator.validate(self.catalog)))

    def test_wrong_argument_type_is_rejected(self):
        self.catalog["strings"]["example"]["localizations"]["en"] = {"stringUnit": {"state": "translated", "value": "%1$@: %2$@"}}
        self.assertTrue(validator.validate(self.catalog))

    def test_required_language_cannot_disappear_from_entire_catalog(self):
        self.assertTrue(any("example/en: missing translation" in error for error in
                            validator.validate(self.catalog, required_languages=("da", "en"))))

    def test_missing_argument_is_rejected(self):
        self.catalog["strings"]["example"]["localizations"]["en"] = {"stringUnit": {"state": "translated", "value": "%lld"}}
        self.assertTrue(validator.validate(self.catalog))

    def test_plural_other_form_is_required(self):
        self.catalog["strings"]["example"]["localizations"]["da"] = {
            "variations": {"plural": {"one": {"stringUnit": {"state": "translated", "value": "%1$lld %2$@"}}}},
        }
        self.assertTrue(validator.validate(self.catalog))

    def test_unknown_format_specifier_is_rejected(self):
        with self.assertRaises(ValueError):
            validator.signature("%n")

    def test_incomplete_plural_branch_is_rejected(self):
        self.catalog["strings"]["example"]["localizations"]["da"] = {
            "variations": {"plural": {
                "one": {"stringUnit": {"state": "translated", "value": "%1$lld %2$@"}},
                "other": {"stringUnit": {"state": "translated", "value": "%lld"}},
            }},
        }
        self.assertTrue(validator.validate(self.catalog))

    def test_explicit_plural_substitution_is_valid(self):
        self.catalog["strings"]["example"]["localizations"]["da"] = self.substitution()
        self.assertEqual(validator.validate(self.catalog), [])
        self.assertEqual(validator.translation_signature(self.substitution()), ["Int", "String"])

    def test_missing_substitution_definition_is_rejected(self):
        node = self.substitution()
        node["substitutions"] = {}
        self.catalog["strings"]["example"]["localizations"]["da"] = node
        self.assertTrue(validator.validate(self.catalog))

    def test_invalid_plural_argument_is_rejected(self):
        node = self.substitution()
        node["substitutions"]["count"]["argNum"] = 0
        self.catalog["strings"]["example"]["localizations"]["da"] = node
        self.assertTrue(validator.validate(self.catalog))

    def test_substitution_branch_requires_count(self):
        node = self.substitution()
        node["substitutions"]["count"]["variations"]["plural"]["other"]["stringUnit"]["value"] = "items"
        self.catalog["strings"]["example"]["localizations"]["da"] = node
        self.assertTrue(validator.validate(self.catalog))

    @staticmethod
    def substitution():
        return {
            "stringUnit": {"state": "translated", "value": "%#@count@: %2$@"},
            "substitutions": {"count": {
                "argNum": 1, "formatSpecifier": "lld", "variations": {"plural": {
                    "one": {"stringUnit": {"state": "translated", "value": "%arg item"}},
                    "other": {"stringUnit": {"state": "translated", "value": "%arg items"}},
                }},
            }},
        }


class NotificationPackagingTests(unittest.TestCase):
    def setUp(self):
        self.catalog = json.loads(validator.NOTIFICATIONS.read_text())

    def test_shipping_push_contract_and_single_source_link(self):
        self.assertEqual(validator.validate_notifications(self.catalog), [])
        self.assertEqual(validator.validate_projection(), [])

    def test_delivery_fixture_keys_and_arguments_match_every_shipping_language(self):
        path = validator.MODULE.parents[1] / "Tests/InsightsTests/Fixtures/feedback-received.apns"
        payload = json.loads(path.read_text())
        self.assertEqual(payload["Simulator Target Bundle"], "dk.nicolaidam.letsgrow")
        self.assertEqual(payload["type"], "FEEDBACK_RECEIVED")
        alert = payload["aps"]["alert"]
        self.assertNotIn("title", alert)
        self.assertNotIn("body", alert)
        for key_field, arguments_field in [("title-loc-key", "title-loc-args"), ("loc-key", "loc-args")]:
            arguments = alert.get(arguments_field, [])
            self.assertTrue(all(isinstance(argument, str) for argument in arguments))
            entry = self.catalog["strings"][alert[key_field]]
            for language, translation in entry["localizations"].items():
                with self.subTest(key=alert[key_field], language=language):
                    self.assertEqual(validator.translation_signature(translation), ["String"] * len(arguments))

    def test_count_must_remain_a_string_argument(self):
        self.body()["value"] = "%1$lld %2$@"
        self.assertTrue(any("APNs requires" in error for error in validator.validate_notifications(self.catalog)))

    def test_payload_key_cannot_disappear(self):
        del self.catalog["strings"]["notification_feedback_received_title"]
        self.assertTrue(validator.validate_notifications(self.catalog))

    def test_editable_duplicate_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            projection = Path(directory) / "Localizable.xcstrings"
            projection.write_text(validator.NOTIFICATIONS.read_text())
            self.assertTrue(validator.validate_projection(projection))

    def test_wrong_link_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "wrong.xcstrings"
            source.write_text("{}")
            projection = Path(directory) / "Localizable.xcstrings"
            projection.symlink_to(source)
            self.assertTrue(validator.validate_projection(projection))

    def test_compiled_bundle_values_and_fallback_are_checked(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory)
            (bundle / "Info.plist").write_bytes(plistlib.dumps({"CFBundleDevelopmentRegion": "da"}))
            for language in ["da", "en"]:
                strings = bundle / f"{language}.lproj/Localizable.strings"
                strings.parent.mkdir()
                values = {key: entry["localizations"][language]["stringUnit"]["value"] for key, entry in self.catalog["strings"].items()}
                strings.write_bytes(plistlib.dumps(values))
            self.assertEqual(validator.validate_app_bundle(bundle, self.catalog), [])
            strings = bundle / "da.lproj/Localizable.strings"
            values = {key: entry["localizations"]["da"]["stringUnit"]["value"] for key, entry in self.catalog["strings"].items()}
            values["notification_feedback_received_title"] = "Old English title"
            strings.write_bytes(plistlib.dumps(values))
            self.assertTrue(validator.validate_app_bundle(bundle, self.catalog))
            (bundle / "Info.plist").write_bytes(plistlib.dumps({"CFBundleDevelopmentRegion": "en"}))
            self.assertTrue(any("development region" in error for error in validator.validate_app_bundle(bundle, self.catalog)))

    def test_unshipped_language_output_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            bundle = Path(directory)
            (bundle / "Info.plist").write_bytes(plistlib.dumps({"CFBundleDevelopmentRegion": "da"}))
            for language in ["da", "en", "de"]:
                strings = bundle / f"{language}.lproj/Localizable.strings"
                strings.parent.mkdir()
                source = "da" if language == "de" else language
                values = {key: entry["localizations"][source]["stringUnit"]["value"] for key, entry in self.catalog["strings"].items()}
                strings.write_bytes(plistlib.dumps(values))
            self.assertTrue(any("unexpected notification localization" in error for error in validator.validate_app_bundle(bundle, self.catalog)))

    def body(self):
        return self.catalog["strings"]["notification_feedback_received_body"]["localizations"]["da"]["stringUnit"]


if __name__ == "__main__":
    unittest.main()

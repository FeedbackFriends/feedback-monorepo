#!/usr/bin/env python3
"""Validate catalog translations and argument signatures; Xcode generates the typed Swift API."""

import argparse
import json
import plistlib
from pathlib import Path
import re
import sys


MODULE = Path(__file__).resolve().parents[2] / "ios-app/Modules/Sources/Localization"
NOTIFICATIONS = MODULE / "AppBundleResources/Localizable.xcstrings"
PROJECTION = MODULE.parents[2] / "Resources/Localizable.xcstrings"
# External APNs payload contract; these are not Swift accessor declarations.
PUSH_SIGNATURES = {
    "notification_feedback_received_body": ["String", "String"],
    "notification_feedback_received_title": [],
    "notification_start_feedback_body": [],
    "notification_start_feedback_title": [],
    "notification_team_invite_received_body": [],
    "notification_team_invite_received_title": [],
}
PLACEHOLDER = re.compile(r"%(?:(\d+)\$)?(lld|@)")


def signature(value):
    """Return argument types in call order, allowing translated positional reordering."""
    types = {}
    next_index = 1
    index = 0
    while index < len(value):
        if value[index] != "%":
            index += 1
            continue
        if value.startswith("%%", index):
            index += 2
            continue
        match = PLACEHOLDER.match(value, index)
        if not match:
            raise ValueError(f"unsupported placeholder at {value[index:]!r}; use %@, %lld or %%")
        position = int(match[1]) if match[1] else next_index
        kind = "String" if match[2] == "@" else "Int"
        if position < 1 or (position in types and types[position] != kind):
            raise ValueError("invalid or conflicting placeholder positions")
        types[position] = kind
        next_index += 1
        index = match.end()
    if set(types) != set(range(1, max(types, default=0) + 1)):
        raise ValueError("placeholder positions must be contiguous starting at 1")
    return [types[i] for i in sorted(types)]


def units(node):
    if "stringUnit" in node:
        yield node["stringUnit"]
        return
    plural = node.get("variations", {}).get("plural")
    if not plural or not {"one", "other"} <= plural.keys():
        raise ValueError("expected a stringUnit or plural with one and other forms")
    for branch in plural.values():
        yield from units(branch)


SUBSTITUTION = re.compile(r"%(?:\d+\$)?#@([^@]+)@")


def translated_values(node):
    """Expand substitution branches to check every rendered argument signature."""
    values = []
    for unit in units(node):
        if unit.get("state") != "translated" or not unit.get("value"):
            raise ValueError("translation must have a nonempty translated value")
        values.append(unit["value"])
    substitutions = node.get("substitutions", {})
    referenced = {name for value in values for name in SUBSTITUTION.findall(value)}
    if referenced != set(substitutions):
        raise ValueError("substitution references must match their definitions")
    for name, substitution in substitutions.items():
        position = substitution.get("argNum")
        specifier = substitution.get("formatSpecifier")
        if type(position) is not int or position < 1 or specifier != "lld":
            raise ValueError("plural substitution requires a positive argNum and lld formatSpecifier")
        branches = list(translated_values(substitution))
        if any("%arg" not in branch for branch in branches):
            raise ValueError("plural substitution must include %arg")
        expanded = []
        for value in values:
            for branch in branches:
                replacement = branch.replace("%arg", f"%{position}$lld")
                expanded.append(SUBSTITUTION.sub(lambda match: replacement if match[1] == name else match[0], value))
        values = expanded
    return values


def translation_signature(node):
    signatures = [signature(value) for value in translated_values(node)]
    if any(actual != signatures[0] for actual in signatures):
        raise ValueError("all plural branches must have the same arguments")
    return signatures[0]


def validate(catalog, required_languages=()):
    errors = []
    if catalog.get("sourceLanguage") != "da":
        errors.append("sourceLanguage must be da")
    entries = catalog.get("strings", {})
    if not entries:
        errors.append("catalog must contain strings")
    languages = {language for entry in entries.values() for language in entry.get("localizations", {})}
    languages.add("da")
    languages.update(required_languages)
    for key, entry in entries.items():
        if not entry.get("comment"):
            errors.append(f"{key}: missing translator comment")
        translations = entry.get("localizations", {})
        try:
            expected = translation_signature(translations["da"])
        except (ValueError, TypeError, KeyError) as error:
            errors.append(f"{key}/da: {error}")
            continue
        for language in sorted(languages):
            if language not in translations:
                errors.append(f"{key}/{language}: missing translation")
                continue
            try:
                actual = translation_signature(translations[language])
                if actual != expected:
                    raise ValueError(f"expected arguments {expected}, found {actual}")
            except (ValueError, TypeError, KeyError) as error:
                errors.append(f"{key}/{language}: {error}")
    return errors


def validate_notifications(catalog, required_languages=()):
    errors = validate(catalog, required_languages=required_languages)
    for key, expected in PUSH_SIGNATURES.items():
        try:
            actual = translation_signature(catalog["strings"][key]["localizations"]["da"])
            if actual != expected:
                errors.append(f"{key}: APNs requires arguments {expected}, found {actual}")
        except (KeyError, TypeError, ValueError) as error:
            errors.append(f"{key}: invalid or missing APNs entry: {error}")
    return errors


def validate_projection(projection=PROJECTION, source=NOTIFICATIONS):
    if not projection.is_symlink() or projection.resolve() != source.resolve() or not source.is_file():
        return ["main-app Localizable.xcstrings must link to the module-owned notification catalog"]
    return []


def validate_app_bundle(bundle, catalog):
    """Inspect native Xcode output without invoking any build/simulator commands."""
    errors = []
    with (bundle / "Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    if info.get("CFBundleDevelopmentRegion") != "da":
        errors.append("app bundle development region must be da")
    languages = {language for entry in catalog["strings"].values() for language in entry["localizations"]}
    for language in languages:
        path = bundle / f"{language}.lproj/Localizable.strings"
        with path.open("rb") as stream:
            compiled = plistlib.load(stream)
        for key, entry in catalog["strings"].items():
            expected = entry["localizations"][language]["stringUnit"]["value"]
            if compiled.get(key) != expected:
                errors.append(f"{language}/{key}: compiled app resource differs from catalog")
    for path in bundle.glob("*.lproj/Localizable.strings"):
        if path.parent.stem not in languages:
            errors.append(f"unexpected notification localization in app bundle: {path.parent.name}")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--catalog", type=Path, help="Validate only this catalog instead of all shipping resources")
    parser.add_argument("--app-bundle", type=Path, help="Also inspect an app bundle built by native Xcode")
    args = parser.parse_args()
    try:
        catalog = json.loads((args.catalog or MODULE / "Resources/AppStrings.xcstrings").read_text())
        errors = validate(catalog, required_languages=("da", "en") if not args.catalog else ())
        count = len(catalog["strings"])
        if not args.catalog:
            notifications = json.loads(NOTIFICATIONS.read_text())
            errors += validate_notifications(notifications, required_languages=("da", "en"))
            errors += validate_projection()
            count += len(notifications["strings"])
            app_languages = {lang for entry in catalog["strings"].values() for lang in entry["localizations"]}
            push_languages = {lang for entry in notifications["strings"].values() for lang in entry["localizations"]}
            if app_languages != push_languages:
                errors.append("AppStrings and notification catalogs must support the same languages")
            if args.app_bundle:
                errors += validate_app_bundle(args.app_bundle, notifications)
        elif args.app_bundle:
            errors.append("--app-bundle cannot be combined with --catalog")
    except (ValueError, OSError, KeyError, IndexError) as error:
        errors = [str(error)]
    if errors:
        print("Localization validation failed:\n" + "\n".join(f"- {e}" for e in errors), file=sys.stderr)
        return 1
    print(f"Localization valid: {count} catalog keys; translations and placeholder signatures agree.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

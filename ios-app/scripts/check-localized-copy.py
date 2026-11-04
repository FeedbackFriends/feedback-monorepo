#!/usr/bin/env python3
"""Guard direct literal prose in common SwiftUI presentation APIs.

This targeted source check complements catalog validation and UI review. It is
not a Swift parser: indirect values, custom component parameters and complex
interpolation still require review. Exceptions are file/value/count specific.
"""

from collections import Counter
from pathlib import Path
import re
import sys


IOS = Path(__file__).resolve().parents[1]
CALL = re.compile(
    r'\b(?:Text|TextState|Button|Label|TextField|SecureField|Section|Toggle|Picker|'
    r'DatePicker|Menu|Link|ShareLink|LabeledContent|ContentUnavailableView|ProgressView|'
    r'navigationTitle|navigationSubtitle|accessibilityLabel|accessibilityHint|'
    r'accessibilityValue|help|alert|confirmationDialog)\s*\(\s*(?:verbatim\s*:\s*)?$'
)
TOKENS = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|(?P<literal>\#*(?:"""[\s\S]*?"""|"(?:\\.|[^"\\])*")\#*)')

# Each entry was reviewed against its actual call site. Counts prevent an
# exception from silently permitting another production copy of the same text.
EXCEPTIONS = {
    'Modules/Sources/DesignSystem/ReusableViews/LetsGrowFeedbackLogoView.swift':
        ('Brand lockup', {'Lets Grow': 1, 'Feedback': 1}),
    'Modules/Sources/DesignSystem/ReusableViews/Banner.swift':
        ('Preview trigger', {'Vis besked': 1}),
    'Modules/Sources/DesignSystem/Styles/ButtonStyles/PrimaryTextButtonStyle.swift':
        ('Preview state samples', {'Aktiveret': 1, 'Deaktiveret': 1}),
    'Modules/Sources/FeedbackFlowFeature/FeedbackFlowCoordinatorView.swift':
        ('Preview toolbar sample', {'Hello': 1}),
    'Modules/Sources/ActivityFeature/ScreenCatalogPreviewView.swift':
        ('Catalog navigation sample', {'Feedback på spørgsmål': 10}),
    'Modules/Sources/ActivityFeature/Events/EventDetail/DetailSectionView.swift':
        ('Preview session titles', {'Session med feedback': 1, 'Session uden feedback': 1}),
    'Modules/Sources/TabbarFeature/NotificationPermissionView.swift':
        ('Preview trigger', {'Vis vindue': 1}),
    'Modules/Sources/FeedbackFlowFeature/ScreenCatalogPreviewView.swift':
        ('Catalog user-authored title sample', {'Ugentligt teammøde': 3}),
}


def literals(source):
    """Yield (line, value) for direct presentation literals containing prose."""
    masked = list(source)
    for token in TOKENS.finditer(source):
        if token.group('literal') and CALL.search(''.join(masked[:token.start()])):
            value = token.group().strip('#').strip('"')
            # Pure interpolation and numeric score endpoints contain no prose.
            static = re.sub(r'\\\([^()]*\)', '', value)
            if any(character.isalpha() for character in static):
                yield source.count('\n', 0, token.start()) + 1, value
        masked[token.start():token.end()] = ['\n' if c == '\n' else ' ' for c in token.group()]


def check(root=IOS, exceptions=None):
    if exceptions is None:
        exceptions = EXCEPTIONS
    failures = []
    scanned = 0
    for folder in [root / 'App', root / 'Modules/Sources']:
        for path in sorted(folder.rglob('*.swift')):
            if 'OpenAPI' in path.relative_to(root).parts:
                continue
            scanned += 1
            relative = path.relative_to(root).as_posix()
            _, allowances = exceptions.get(relative, ('', {}))
            used = Counter()
            for line, value in literals(path.read_text()):
                used[value] += 1
                if used[value] > allowances.get(value, 0):
                    failures.append(f'{relative}:{line}: move visible prose to Localization: {value!r}')
            for value, expected in allowances.items():
                if used[value] < expected:
                    failures.append(
                        f'{relative}: stale localization exception for {value!r}: '
                        f'expected {expected}, found {used[value]}'
                    )
    for relative in exceptions:
        if not (root / relative).is_file():
            failures.append(f'{relative}: stale localization exception: file is missing')
    return scanned, failures


if __name__ == '__main__':
    count, errors = check()
    if errors:
        print('\n'.join(errors), file=sys.stderr)
        sys.exit(1)
    print(f'Localized-copy guard passed: {count} Swift files; reviewed brand/preview exceptions only.')

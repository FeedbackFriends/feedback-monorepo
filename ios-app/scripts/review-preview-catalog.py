#!/usr/bin/env python3
"""Compare the captured catalog with approved PNGs; explicitly accept reviewed changes."""
import argparse
import hashlib
import html
import importlib.util
import json
from pathlib import Path
import shutil
import sys

from PIL import Image, ImageChops

ROOT = Path(__file__).resolve().parents[1]
BASELINE = ROOT / 'Docs/screenshots/catalog'
CURRENT = ROOT.parent / 'screenshots/current'
REVIEW = ROOT.parent / 'screenshots/review'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.exists() else None


def compare(before, after):
    """Compare decoded RGBA pixels, ignoring PNG compression and metadata."""
    with Image.open(before) as old, Image.open(after) as new:
        old, new = old.convert('RGBA'), new.convert('RGBA')
        if old.size != new.size:
            return False, None, None
        channels = ImageChops.difference(old, new).split()
        mask = channels[0]
        for channel in channels[1:]:
            mask = ImageChops.lighter(mask, channel)
        mask = mask.point(lambda value: 255 if value else 0)
        changed = mask.histogram()[255]
        overlay = new.copy()
        overlay.paste((255, 0, 100, 255), mask=mask)
        return changed == 0, changed / (old.width * old.height) * 100, overlay


def review(baseline=BASELINE, current=CURRENT, output=REVIEW, excluded=(), pixel_comparison=True, page=None):
    if not current.is_dir() or not list(current.glob('*.png')):
        raise ValueError('No current captures. Publish a complete native Xcode capture batch first.')
    before = {p.stem: p for p in baseline.glob('*.png') if p.stem not in excluded}
    after = {p.stem: p for p in current.glob('*.png') if p.stem not in excluded}
    # Read and compare the entire batch before replacing the previous report.
    changes, unchanged = [], 0
    for identifier in sorted(before.keys() | after.keys()):
        old, new = before.get(identifier), after.get(identifier)
        status, percent, difference = ('changed' if pixel_comparison else 'needs-review'), None, None
        if old and new and pixel_comparison:
            equal, percent, difference = compare(old, new)
            if equal:
                unchanged += 1
                continue
        elif not (old and new):
            status = 'added' if new else 'removed'
        for path in (old, new):
            if path:
                with Image.open(path) as img:
                    img.load()
        changes.append(({'id': identifier, 'status': status, 'percent': percent,
                         'beforeHash': digest(old) if old else None,
                         'afterHash': digest(new) if new else None}, old, new, difference))
    output.mkdir(parents=True, exist_ok=True)
    for directory in ('before', 'after', 'diff'):
        target = output / directory
        if target.exists():
            shutil.rmtree(target)
        target.mkdir()
    cards = []
    for entry, old, new, difference in changes:
        name = entry['id'] + '.png'
        sources = (('before', old), ('after', new)) if pixel_comparison else (('after', new),)
        for directory, source in sources:
            if source:
                shutil.copyfile(source, output / directory / name)
        if difference:
            difference.save(output / 'diff' / name)
        title = html.escape(entry['id'])
        images = []
        displayed = (('before', old), ('after', new), ('diff', difference)) if pixel_comparison else (('after', new),)
        for label, available in displayed:
            if available:
                images.append(f'<figure><figcaption>{label.title()}</figcaption><a href="{label}/{name}"><img loading="lazy" src="{label}/{name}" alt="{title} {label}"></a></figure>')
        metric = f" · {entry['percent']:.4f}% pixels changed" if entry['percent'] is not None else ''
        slider = ''
        if old and new and difference:
            slider = f'''<details><summary>Compare with slider</summary><label>Before / After <input type="range" min="0" max="100" value="50" oninput="this.parentElement.nextElementSibling.style.setProperty('--split',this.value+'%')"></label><div class="overlay"><img src="before/{name}" alt="Before"><img src="after/{name}" alt="After"></div></details>'''
        if pixel_comparison:
            cards.append(f'<article><h2>{title}</h2><p>{entry["status"]}{metric}</p><div class="images">{"".join(images)}</div>{slider}</article>')
        elif new:
            cards.append(f'<article><h2>{title}</h2><a href="after/{name}"><img loading="lazy" src="after/{name}" alt="{title}"></a></article>')
    summary = {status: sum(e[0]['status'] == status for e in changes) for status in ('changed', 'added', 'removed')}
    if pixel_comparison:
        summary['unchanged'] = unchanged
    else:
        summary.pop('changed')
        summary['needs-review'] = sum(e[0]['status'] == 'needs-review' for e in changes)
    report = {'reviewMode': 'pixels' if pixel_comparison else 'visual', 'baseline': str(baseline.resolve()), 'manualReviewIds': sorted(excluded), 'summary': summary, 'changes': [e[0] for e in changes]}
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    if excluded:
        summary['manualReview'] = len(excluded)
    counts = ' · '.join(f'{count} {status}' for status, count in summary.items())
    document = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>LetsGrow screenshot review</title>
<style>body{font:16px system-ui;margin:32px;background:#f4f5f7;color:#17202b}main{max-width:1400px;margin:auto}article{background:white;padding:24px;margin:24px 0;border-radius:16px}h2{overflow-wrap:anywhere}.images{display:flex;gap:20px;align-items:flex-start;overflow:auto}figure{margin:0;flex:1;min-width:180px}figcaption{margin-bottom:12px}img{max-width:100%;height:auto;background:repeating-conic-gradient(#eee 0% 25%,white 0% 50%) 50%/16px 16px}figure img{max-height:650px;object-fit:contain;object-position:top}details{margin-top:20px}summary{cursor:pointer}label{display:block;margin:16px 0}.overlay{position:relative;max-width:430px;--split:50%}.overlay img{display:block;width:100%}.overlay img+img{position:absolute;inset:0;clip-path:inset(0 0 0 var(--split))}</style><main><h1>Screenshot review</h1>'''
    if not pixel_comparison:
        document += '<style>main{max-width:1600px}.gallery{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:20px;align-items:start}.gallery article{margin:0;padding:12px;border:1px solid #e1e5eb;border-radius:12px;min-width:0}.gallery h2{font-size:14px;margin:0 0 12px;font-weight:600}.gallery a{display:block}.gallery img{display:block;width:100%;border-radius:6px}@media(max-width:520px){body{margin:16px}.gallery{grid-template-columns:repeat(2,minmax(0,1fr));gap:12px}.gallery article{padding:8px}.gallery h2{font-size:12px}}</style>'
    explanation = 'Pink marks changed pixels; pixel differences are diagnostic only.' if pixel_comparison else 'Current screenshots. Click a screenshot to open it at full size.'
    if pixel_comparison:
        document += f'<p>{counts}</p><p>{explanation} Click an image for full size.</p>'
    else:
        document += f'<p>{len(after)} screenshots · {explanation}</p>'
    document += '<div class="gallery">' + (''.join(cards) or '<p>No screenshots.</p>') + '</div>'
    page = page or output / 'index.html'
    if page.parent != output:
        assets = html.escape(output.relative_to(page.parent).as_posix()) + '/'
        document = document.replace('<meta charset=', f'<base href="{assets}"><meta charset=', 1)
    page.write_text(document + '</main></html>')
    return summary


def accept(output=REVIEW, identifiers=None, all_changes=False):
    report = json.loads((output / 'report.json').read_text())
    if report.get('repeatCheck'):
        raise ValueError('Repeat checks cannot be accepted as approved baselines.')
    baseline = Path(report['baseline'])
    entries = {entry['id']: entry for entry in report['changes']}
    selected = list(entries) if all_changes else identifiers or []
    if not selected or set(selected) - entries.keys():
        raise ValueError('Choose screen IDs from the review report, or --accept-all when it has changes.')
    # Validate all approvals before writing any baseline files.
    for identifier in selected:
        entry = entries[identifier]
        if digest(baseline / f'{identifier}.png') != entry['beforeHash']:
            raise ValueError(f'Baseline changed since review: {identifier}. Generate a fresh report.')
        if digest(output / 'after' / f'{identifier}.png') != entry['afterHash']:
            raise ValueError(f'Review image changed: {identifier}. Generate a fresh report.')
    baseline.mkdir(parents=True, exist_ok=True)
    for identifier in selected:
        entry = entries[identifier]
        target = baseline / f'{identifier}.png'
        if entry['status'] == 'removed':
            target.unlink()
        else:
            shutil.copyfile(output / 'after' / target.name, target)
    return len(selected)


def check_repeat(first, second, output):
    first_ids = {path.stem for path in first.glob('*.png')}
    second_ids = {path.stem for path in second.glob('*.png')}
    if not first_ids or first_ids != second_ids:
        raise ValueError('Repeat captures must contain the same nonempty set of screen IDs.')
    summary = review(first, second, output)
    # A repeat check is diagnostic only: it can never authorize baseline acceptance.
    report_path = output / 'report.json'
    report = json.loads(report_path.read_text())
    report['repeatCheck'] = True
    report_path.write_text(json.dumps(report, indent=2) + '\n')
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument('--accept', nargs='+', metavar='SCREEN_ID')
    action.add_argument('--accept-all', action='store_true')
    action.add_argument('--check-repeat', nargs=2, type=Path, metavar=('FIRST', 'SECOND'))
    parser.add_argument('--pixel-diff', action='store_true', help='Optional pixel diagnostics instead of the complete visual gallery')
    args = parser.parse_args()
    if args.check_repeat:
        output = ROOT.parent / 'screenshots/repeat-review'
        summary = check_repeat(*args.check_repeat, output)
        print(json.dumps(summary))
        print(output / 'index.html')
        return 0  # Numerical differences are diagnostic, never a visual approval gate.
    if args.accept or args.accept_all:
        print(f'Accepted {accept(identifiers=args.accept, all_changes=args.accept_all)} screenshots.')
    else:
        spec = importlib.util.spec_from_file_location('publisher', ROOT / 'scripts/screen-catalog.py')
        publisher = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(publisher)
        expected = {screen['id'] for screen in publisher.load_registry()['screens']}
        actual = {path.stem for path in CURRENT.glob('*.png')}
        if actual != expected:
            raise ValueError('Current captures do not match the complete preview plan. Recapture before reviewing.')
        page = REVIEW.parent / 'index.html'
        print(json.dumps(review(pixel_comparison=args.pixel_diff, page=page)))
        (REVIEW / 'index.html').unlink(missing_ok=True)
        print(page)


if __name__ == '__main__':
    sys.exit(main())

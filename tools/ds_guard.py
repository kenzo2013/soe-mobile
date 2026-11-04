#!/usr/bin/env python3
"""Measure what bypasses the SOE design system and the v2 conventions in lib/.

Each rule is a pattern that must not appear outside the files allowed to define it (the
theme for colours and text styles, the shared widgets for raw Material widgets). The count
is per OCCURRENCE. The baseline file stores the count of each rule: a rule may go down,
never up (ratchet).

Usage:
    python3 tools/ds_guard.py                     # summary + worst files
    python3 tools/ds_guard.py --check             # exit 1 if a rule is above its baseline
    python3 tools/ds_guard.py --update-baseline   # after a clean-up only
    python3 tools/ds_guard.py --files a.dart b.dart   # list the hits in these files
"""
import argparse
import collections
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
BASELINE = ROOT / 'tools' / 'ds_guard.baseline.json'
THEME = 'lib/core/theme/'
WIDGETS = 'lib/core/widgets/'
GENERATED = ('.g.dart', '.freezed.dart', '.gr.dart')

# name -> (pattern, paths where it is allowed, fix)
RULES = {
    'font_size': (r'\bfontSize\s*:', (THEME,), 'AppTypography.* / textTheme'),
    # countries.dart: national flag colours are data, not brand colours.
    'color_literal': (r'\bColor\(0x|\bColors\.(?!transparent\b)[a-z]',
                      (THEME, 'lib/core/data/countries.dart'), 'AppPalette.*'),
    'text_style_ctor': (r'\bTextStyle\(', (THEME, WIDGETS), 'AppTypography.*.copyWith(...)'),
    'raw_snackbar': (r'\bshowSnackBar\(|\bSnackBar\(', (WIDGETS,), 'SoeToast.show(...)'),
    'raw_material_button': (r'\b(ElevatedButton|TextButton|OutlinedButton|FilledButton)\b',
                            (WIDGETS, THEME), 'SoeButton'),
    'raw_text_field': (r'\b(TextField|TextFormField)\(', (WIDGETS,), 'SoeTextField / SoePasswordField'),
    'raw_dialog': (r'\b(showDialog|AlertDialog)\b', (WIDGETS,), 'SoeConfirmDialog'),
    'gradient': (r'\b(LinearGradient|RadialGradient)\(', (THEME, WIDGETS), 'flat AppPalette surface (v2: no gradient)'),
    'state_notifier': (r'\bStateNotifier(Provider)?\b', (), 'Notifier / AsyncNotifier (v2 decision)'),
    'hardcoded_text': (r"""\bText\(\s*['"][^'"$]*[A-Za-zÀ-ÿ]{2}""", (), 'Translations.of(context).x'),
    'raw_edge_insets': (r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*\b\d+(\.\d+)?\b', (THEME,),
                        'AppSpacing.*'),
    'print_call': (r'(?<![\w.])print\(', (), 'logger'),
}
COMPILED = {name: re.compile(rule[0]) for name, rule in RULES.items()}
COMMENT = re.compile(r'//.*$', re.M)


def dart_files(selected=None):
    if selected:
        return [ROOT / f for f in selected if f.endswith('.dart')]
    return sorted(p for p in (ROOT / 'lib').rglob('*.dart')
                  if not p.name.endswith(GENERATED) and 'lib/i18n/' not in str(p))


def scan(selected=None):
    hits = collections.defaultdict(list)
    for path in dart_files(selected):
        relative = str(path.relative_to(ROOT))
        lines = COMMENT.sub('', path.read_text(encoding='utf-8', errors='replace')).splitlines()
        for name, (_, allowed, _) in RULES.items():
            if any(relative.startswith(prefix) for prefix in allowed):
                continue
            for number, line in enumerate(lines, 1):
                hits[name].extend((relative, number) for _ in COMPILED[name].finditer(line))
    return hits


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--check', action='store_true', help='exit 1 if a rule is above its baseline')
    parser.add_argument('--update-baseline', action='store_true', help='write the current counts')
    parser.add_argument('--files', nargs='+', help='only these files, list every hit')
    args = parser.parse_args()

    hits = scan(args.files)
    if args.files:
        for name, found in hits.items():
            for path, line in found:
                print(f"{path}:{line}  {name}  -> {RULES[name][2]}")
        return 1 if any(hits.values()) else 0

    counts = {name: len(hits[name]) for name in RULES}
    for name in RULES:
        worst = collections.Counter(path for path, _ in hits[name]).most_common(1)
        where = f"  (worst: {worst[0][0]} x{worst[0][1]})" if worst else ''
        print(f"  {name:<20} {counts[name]:>5}{where}")
    print(f"\n  TOTAL {sum(counts.values())}")

    if args.update_baseline:
        BASELINE.write_text(json.dumps(counts, indent=2) + '\n', encoding='utf-8')
        print('\nBaseline written.')
    if args.check:
        baseline = json.loads(BASELINE.read_text(encoding='utf-8'))
        above = {n: (c, baseline.get(n, 0)) for n, c in counts.items() if c > baseline.get(n, 0)}
        for name, (count, limit) in above.items():
            print(f"FAIL {name}: {count} > {limit}. Fix: {RULES[name][2]}")
        if above:
            return 1
        print('\nOK: no rule above its baseline.')
        if any(c < baseline.get(n, 0) for n, c in counts.items()):
            print('Lower the ratchet: python3 tools/ds_guard.py --update-baseline')
    return 0


if __name__ == '__main__':
    sys.exit(main())

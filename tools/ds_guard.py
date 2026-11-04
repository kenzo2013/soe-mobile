#!/usr/bin/env python3
"""Measure what bypasses the SOE design system and the v2 conventions in lib/.

Each rule is a pattern that must not appear outside the files allowed to define it (the
theme for colours and text styles, the shared widgets for raw Material widgets). Patterns
are matched on the whole file, so code that `dart format` wraps over several lines is seen.
Comments (`//`, `///`, `/* */`) are ignored; string contents are kept (hard-coded text is a rule).

The baseline stores the count of each rule: a rule may go down, never up (ratchet).

Usage:
    python3 tools/ds_guard.py                     # summary + worst file per rule
    python3 tools/ds_guard.py --check             # exit 1 if a rule is above its baseline
    python3 tools/ds_guard.py --diff refonte/v2   # exit 1 if a file changed since that ref got worse
                                                  # (a new file must have no hit at all)
    python3 tools/ds_guard.py --files a.dart      # every hit in these files, with the fix
    python3 tools/ds_guard.py --update-baseline   # after a clean-up (refuses to go up)
"""
import argparse
import collections
import json
import pathlib
import re
import subprocess
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
    'gradient': (r'\b(LinearGradient|RadialGradient)\(', (THEME, WIDGETS),
                 'flat AppPalette surface (v2: no gradient)'),
    'state_notifier': (r'\bStateNotifier(Provider)?\b', (), 'Notifier / AsyncNotifier (v2 decision)'),
    'hardcoded_text': (r"""\bText\(\s*['"][^'"$]*[A-Za-zÀ-ÿ]{2}""", (), 'Translations.of(context).x'),
    'raw_edge_insets': (r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*?\b\d+(\.\d+)?\b', (THEME,),
                        'AppSpacing.*'),
    'print_call': (r'(?<![\w.])print\(', (), 'logger'),
}
COMPILED = {name: re.compile(rule[0]) for name, rule in RULES.items()}
STRING = re.compile(r"'''.*?'''|\"\"\".*?\"\"\"|'(?:\\.|[^'\\\n])*'|\"(?:\\.|[^\"\\\n])*\"", re.S)
COMMENT = re.compile(r'/\*.*?\*/|//[^\n]*', re.S)


def strip_comments(source):
    """Blank out comments (keeping offsets), never touching `//` inside a string."""
    masked = STRING.sub(lambda m: m.group(0)[0] + ' ' * (len(m.group(0)) - 2) + m.group(0)[-1], source)
    chars = list(source)
    for m in COMMENT.finditer(masked):
        for i in range(m.start(), m.end()):
            if chars[i] != '\n':
                chars[i] = ' '
    return ''.join(chars)


def is_scanned(relative):
    return (relative.startswith('lib/') and relative.endswith('.dart')
            and not relative.endswith(GENERATED) and not relative.startswith('lib/i18n/'))


def hits_in(relative, source):
    """rule -> list of line numbers."""
    code = strip_comments(source)
    found = collections.defaultdict(list)
    for name, (_, allowed, _) in RULES.items():
        if any(relative.startswith(prefix) for prefix in allowed):
            continue
        for m in COMPILED[name].finditer(code):
            found[name].append(code.count('\n', 0, m.start()) + 1)
    return found


def scan_tree():
    totals = collections.defaultdict(list)
    for path in sorted((ROOT / 'lib').rglob('*.dart')):
        relative = str(path.relative_to(ROOT))
        if not is_scanned(relative):
            continue
        for name, lines in hits_in(relative, path.read_text(encoding='utf-8', errors='replace')).items():
            totals[name].extend((relative, line) for line in lines)
    return totals


def git(*args):
    return subprocess.run(['git', *args], cwd=ROOT, capture_output=True, text=True, check=False)


def diff_against(ref):
    """Files changed since `ref` (committed or not) must not get worse; new files must be clean."""
    changed = git('diff', '--name-only', '--diff-filter=d', ref, '--', 'lib').stdout.split()
    changed += git('ls-files', '--others', '--exclude-standard', 'lib').stdout.split()
    worse = []
    for relative in sorted(set(f for f in changed if is_scanned(f))):
        now = hits_in(relative, (ROOT / relative).read_text(encoding='utf-8', errors='replace'))
        before_source = git('show', f'{ref}:{relative}')
        before = hits_in(relative, before_source.stdout) if before_source.returncode == 0 else {}
        for name, lines in now.items():
            if len(lines) > len(before.get(name, [])):
                worse.append((relative, name, len(before.get(name, [])), len(lines), lines))
    for relative, name, old, new, lines in worse:
        print(f"{relative}: {name} {old} -> {new} (lines {', '.join(map(str, lines))}). Fix: {RULES[name][2]}")
    if not worse:
        print(f"OK: no file changed since {ref} got worse ({len(changed)} files checked).")
    return 1 if worse else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--check', action='store_true', help='exit 1 if a rule is above its baseline')
    parser.add_argument('--diff', metavar='REF', help='exit 1 if a file changed since REF got worse')
    parser.add_argument('--files', nargs='*', help='every hit in these files')
    parser.add_argument('--update-baseline', action='store_true', help='write the current counts')
    parser.add_argument('--allow-increase', action='store_true',
                        help='with --update-baseline: only in the commit that adds or widens a rule')
    args = parser.parse_args()

    if args.diff:
        return diff_against(args.diff)
    if args.files is not None:
        status = 0
        for relative in args.files:
            path = ROOT / relative
            if not is_scanned(relative) or not path.exists():
                continue
            for name, lines in hits_in(relative, path.read_text(encoding='utf-8', errors='replace')).items():
                status = 1
                for line in lines:
                    print(f"{relative}:{line}  {name}  -> {RULES[name][2]}")
        return status

    hits = scan_tree()
    counts = {name: len(hits[name]) for name in RULES}
    for name in RULES:
        worst = collections.Counter(path for path, _ in hits[name]).most_common(1)
        where = f"  (worst: {worst[0][0]} x{worst[0][1]})" if worst else ''
        print(f"  {name:<20} {counts[name]:>5}{where}")
    print(f"\n  TOTAL {sum(counts.values())}")

    baseline = json.loads(BASELINE.read_text(encoding='utf-8')) if BASELINE.exists() else {}
    if args.update_baseline:
        raised = {n: (baseline[n], c) for n, c in counts.items() if n in baseline and c > baseline[n]}
        if raised and not args.allow_increase:
            for name, (old, new) in raised.items():
                print(f"REFUSED {name}: {new} > {old}. Thresholds only go down: fix the new hits.")
            return 1
        BASELINE.write_text(json.dumps(counts, indent=2) + '\n', encoding='utf-8')
        print('\nBaseline written.')
        return 0
    if args.check:
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

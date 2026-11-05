import 'package:flutter/material.dart';

/// SOE palette — design system v2 (Studio, "Fondations").
///
/// Mirror of the web tokens (`soe/app/javascript/design/tokens.cjs`): a value changed here
/// must change there too. New code uses the scale names (`teal500`, `gold400`, `ink700`,
/// `n50`, `successText`...). The short names further down are kept for the v1 screens.
abstract final class AppPalette {
  // Teal — brand. 500, 600, 800 = charter.
  static const Color teal50 = Color(0xFFEEF5F8);
  static const Color teal100 = Color(0xFFD5E7EE);
  static const Color teal200 = Color(0xFFA9CEDB);
  static const Color teal300 = Color(0xFF7FB3C5);
  static const Color teal400 = Color(0xFF3F8AA3);
  static const Color teal500 = Color(0xFF035E7B);
  static const Color teal600 = Color(0xFF024A62);
  static const Color teal700 = Color(0xFF013E56);
  static const Color teal800 = Color(0xFF01324A);
  static const Color teal900 = Color(0xFF01202F);

  // Gold — action. Never a surface background, never white text on it.
  static const Color gold50 = Color(0xFFFFF7E5);
  static const Color gold100 = Color(0xFFFFEBBF);
  static const Color gold400 = Color(0xFFFFB000);
  static const Color gold500 = Color(0xFFE59E00);
  static const Color gold700 = Color(0xFF8A5F00);

  // Inks and neutrals.
  static const Color ink900 = Color(0xFF010814);
  static const Color ink700 = Color(0xFF526684);
  static const Color ink600 = Color(0xFF60748F);
  static const Color ink400 = Color(0xFFA3BCE2);
  // Colourful direction: the light neutrals take the teal tint of the page ground (lines,
  // soft fills, disabled), instead of the grey-blue of the web tokens.
  static const Color n0 = Color(0xFFFCFDFF);
  static const Color n50 = Color(0xFFF3F8FA);
  static const Color n100 = teal50;
  static const Color n300 = teal100;
  static const Color white = Color(0xFFFFFFFF);

  // States: charter colour (icons, bars) + AA text variant + tinted background.
  static const Color success = Color(0xFF028226);
  static const Color successText = Color(0xFF016B1F);
  static const Color successBg = Color(0xFFE6F5EA);
  static const Color warning = Color(0xFFFF7A00);
  static const Color warningText = Color(0xFFA34B00);
  static const Color warningBg = Color(0xFFFFEEDD);
  static const Color danger = Color(0xFFFF3F3F);
  static const Color dangerText = Color(0xFFC62828);
  static const Color dangerBg = Color(0xFFFFE6E6);
  static const Color info = Color(0xFF035E7B);
  static const Color infoText = Color(0xFF024A62);
  static const Color infoBg = Color(0xFFDCEAFF);

  // Subjects (dot only; the text stays ink).
  static const Color subjectMaths = Color(0xFF035E7B);
  static const Color subjectFrench = Color(0xFFE59E00);
  static const Color subjectEnglish = Color(0xFF028226);
  static const Color subjectPhysics = Color(0xFF3F8AA3);
  static const Color subjectBiology = Color(0xFF016B1F);
  static const Color subjectHistory = Color(0xFFA34B00);
  static const Color subjectPhilosophy = Color(0xFF526684);
  static const Color subjectComputing = Color(0xFF01324A);

  // Colourful direction (2026-11): the brand grounds of the bands, the slides and the chips.
  /// Header band of the tutor space and of the account, the navigation, the launch screen.
  static const Color navy = teal800;

  /// Header band of the parent space.
  static const Color parentBand = teal500;

  /// The band of a role's space: SOE teal for a parent, navy otherwise.
  static Color band(String? role) => role == 'parent' ? parentBand : navy;

  /// Urgency: countdowns, disputed (text [warningText] on [warningBg]).
  static const Color orange = warning;

  /// Grounds of the welcome slides (« Chaque séance suivie », « Un contrat clair »).
  static const Color greenDeep = Color(0xFF014A2A);
  static const Color orangeDeep = Color(0xFF5A2A00);

  /// Text on a gold chip.
  static const Color goldInk = Color(0xFF3A2900);

  /// Inactive icons of the navigation, secondary text on navy.
  static const Color navInactive = Color(0xFFC5D8E6);

  /// The active tab (translucent grey pill) and the bell circle on a band.
  static const Color onBandActive = Color(0x29FFFFFF);
  static const Color onBandSoft = Color(0x1FFFFFFF);

  // Roles.
  /// Page ground: light teal, so that the white cards stand out.
  static const Color surfacePage = teal50;
  static const Color surfaceSoft = teal50;
  static const Color surfaceSunken = n100;
  static const Color surfaceCard = white;
  static const Color surfaceNav = teal800;
  static const Color text = ink900;
  static const Color text2 = ink700;
  static const Color text3 = ink600;
  static const Color border = n300;
  static const Color onDark = white;
  static const Color onDark2 = Color(0xFFC5D8E6);
  static const Color scrim = Color(0x73010814);
  static const Color overlayHover = Color(0x0F010814);
  static const Color overlayPress = Color(0x1F010814);
  static const Color overlayDarkHover = Color(0x1AFFFFFF);
  static const Color lineDark = Color(0x1FFFFFFF);

  // ── v1 names (kept until every screen is rebuilt; do not use in new code) ──
  static const Color teal = teal500;
  static const Color tealDeep = teal600;
  static const Color tealDark = teal800;
  static const Color yellow = gold400;
  static const Color yellowDeep = gold500;
  static const Color ink = ink900;
  static const Color ink2 = ink700;
  static const Color ink3 = ink400;
  static const Color n900 = ink900;
  static const Color n700 = ink700;
  static const Color n500 = ink400;
  static const Color primary = gold400;
  static const Color secondary = teal500;
  static const Color textPrimary = ink900;
  static const Color textSecondary = ink700;
  static const Color textTertiary = ink400;
  static const Color surface = white;
  static const Color surfaceLight = n50;
  static const Color surfaceAccent = n300;
  static const Color background = n100;
  static const Color error = danger;

  /// v1 brand gradient. v2 surfaces are flat (`surfaceNav`): do not use in new screens.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.55, 1],
    colors: [ink900, teal800, teal500],
  );
}

/// The colour of a school subject (web tokens), from its name in French or English.
abstract final class SubjectColors {
  static Color of(String? subject) {
    final name = (subject ?? '').toLowerCase();
    bool has(List<String> words) => words.any(name.contains);
    if (has(['math'])) return AppPalette.subjectMaths;
    if (has(['fran', 'french'])) return AppPalette.subjectFrench;
    if (has(['angl', 'english'])) return AppPalette.subjectEnglish;
    if (has(['phys', 'chim', 'chem'])) return AppPalette.subjectPhysics;
    if (has(['svt', 'bio', 'vie et'])) return AppPalette.subjectBiology;
    if (has(['hist', 'géo', 'geo'])) return AppPalette.subjectHistory;
    if (has(['philo'])) return AppPalette.subjectPhilosophy;
    if (has(['info', 'comput'])) return AppPalette.subjectComputing;
    return AppPalette.teal500;
  }

  /// The text on a subject's colour: ink on the golden French, white otherwise.
  static Color onColor(Color color) =>
      color == AppPalette.subjectFrench ? AppPalette.ink900 : AppPalette.white;
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../i18n/translations.g.dart';

/// En-tête de page d'inscription : back, titre, indicateur d'étape, progress.
class SignupHeader extends StatelessWidget implements PreferredSizeWidget {
  const SignupHeader({super.key, required this.step, this.total = 4});

  final int step;
  final int total;

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Row(
              children: [
                _BackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(tr.signup.title, style: AppTypography.h4),
                ),
                Text(
                  tr.signup.step(current: step, total: total),
                  style: AppTypography.label.copyWith(
                      color: AppPalette.n700, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 5,
                child: Stack(
                  children: [
                    Container(color: AppPalette.n300),
                    FractionallySizedBox(
                      widthFactor: step / total,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: AppPalette.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.n100,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.chevron_left, color: AppPalette.ink),
        ),
      ),
    );
  }
}

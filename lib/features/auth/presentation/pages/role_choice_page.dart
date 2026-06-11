import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/lang_pill.dart';
import '../../../../core/widgets/soe_app_bar.dart';
import '../../../../core/widgets/soe_brand_logo.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/user.dart';
import '../viewmodels/register_flow_viewmodel.dart';

class RoleChoicePage extends ConsumerStatefulWidget {
  const RoleChoicePage({super.key});

  @override
  ConsumerState<RoleChoicePage> createState() => _RoleChoicePageState();
}

class _RoleChoicePageState extends ConsumerState<RoleChoicePage> {
  UserRole _role = UserRole.parent;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SoeAppBar(
        title: '',
        actions: [
          Padding(padding: EdgeInsets.only(right: 16), child: LangPill()),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: SoeBrandLogo(width: 110)),
              const SizedBox(height: 24),
              Text(tr.role.title,
                  style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                tr.role.subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(color: AppPalette.n700),
              ),
              const SizedBox(height: 28),
              _RoleTile(
                icon: Icons.groups_outlined,
                title: tr.role.parent.title,
                body: tr.role.parent.body,
                selected: _role == UserRole.parent,
                onTap: () => setState(() => _role = UserRole.parent),
              ),
              const SizedBox(height: 12),
              _RoleTile(
                icon: Icons.school_outlined,
                title: tr.role.tutor.title,
                body: tr.role.tutor.body,
                selected: _role == UserRole.tutor,
                onTap: () => setState(() => _role = UserRole.tutor),
              ),
              const SizedBox(height: 24),
              SoeButton(
                label: tr.common.kContinue,
                icon: Icons.chevron_right,
                iconRight: true,
                size: SoeButtonSize.lg,
                fullWidth: true,
                onPressed: () {
                  ref
                      .read(registerFlowViewModelProvider.notifier)
                      .setRole(_role);
                  context.push(RouteNames.registerStep1);
                },
              ),
              const SizedBox(height: 18),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text('${tr.role.alreadyAccount} ',
                        style: AppTypography.bodySm
                            .copyWith(color: AppPalette.n700)),
                    GestureDetector(
                      onTap: () => context.go(RouteNames.login),
                      child: Text(
                        tr.role.signIn,
                        style: AppTypography.bodySm.copyWith(
                          color: AppPalette.teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppPalette.teal : AppPalette.n300;
    final iconBg = selected ? AppPalette.teal : AppPalette.n100;
    final iconColor = selected ? AppPalette.white : AppPalette.teal;
    final bg = selected ? AppPalette.n300 : AppPalette.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.rMd,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: AppRadius.rSm,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.h4),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style:
                          AppTypography.bodySm.copyWith(color: AppPalette.n700),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppPalette.teal : AppPalette.n500,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppPalette.teal,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

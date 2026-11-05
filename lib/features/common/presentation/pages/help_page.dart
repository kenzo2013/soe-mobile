import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// COM-10 — the FAQ by topic, the official contacts (e-mail, Cameroon and France numbers for
/// calls and WhatsApp) and the emergency way. The app has no link opener yet: a contact is
/// copied, ready to paste in the phone, WhatsApp or the mail app.
class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});

  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  String? _topic;
  bool _all = false;
  int? _open;

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      SoeToast.show(context,
          message:
              Translations.of(context).accountSpace.help.copied(value: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.help;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    return AccountScaffold(
      title: tr.crumbTitle,
      crumb: tr.crumb,
      onRefresh: () => ref.refresh(helpProvider.future),
      children: [
        AccountPageTitle(tr.title, subtitle: tr.intro),
        AccountAsync<HelpContent>(
          value: ref.watch(helpProvider),
          onRetry: () => ref.invalidate(helpProvider),
          builder: (help) {
            final key = _topic ?? help.defaultTopic;
            final topic =
                help.topics.where((topic) => topic.key == key).firstOrNull ??
                    help.topics.firstOrNull;
            final questions = topic?.questions ?? const [];
            final shown = _all ? questions : questions.take(3).toList();
            final phone = help.phones.firstOrNull;
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final item in help.topics)
                      SoeChip(
                        label: item.label,
                        selected: item.key == topic?.key,
                        onTap: () => setState(() {
                          _topic = item.key;
                          _all = false;
                          _open = null;
                        }),
                      ),
                  ]),
                  const SizedBox(height: 16),
                  AccountCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: AccountCardTitle(tr.faq),
                          ),
                          for (final (index, question) in shown.indexed)
                            AccountRow(
                              icon: Icons.chat_bubble_outline,
                              title: question.question,
                              subtitle: _open == index ? question.answer : null,
                              trailing: Icon(
                                  _open == index
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppPalette.text2),
                              onTap: () => setState(
                                  () => _open = _open == index ? null : index),
                            ),
                          if (!_all && questions.length > shown.length)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: SoeButton(
                                label: tr.allQuestions,
                                variant: SoeButtonVariant.tertiary,
                                size: SoeButtonSize.sm,
                                onPressed: () => setState(() => _all = true),
                              ),
                            ),
                        ]),
                  ),
                  AccountCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountCardTitle(tr.contact),
                          Text(tr.contactIntro,
                              style: AppTypography.body
                                  .copyWith(color: AppPalette.text2)),
                          const SizedBox(height: 8),
                          AccountInfoLine(label: tr.email, value: help.email),
                          for (final (index, item) in help.phones.indexed)
                            AccountInfoLine(
                                label: item.label,
                                value: item.display,
                                last: index == help.phones.length - 1),
                          const SizedBox(height: 16),
                          Wrap(spacing: 8, runSpacing: 8, children: [
                            if (phone != null) ...[
                              SoeButton(
                                label: tr.call,
                                variant: SoeButtonVariant.outline,
                                size: SoeButtonSize.md,
                                onPressed: () => unawaited(_copy(phone.number)),
                              ),
                              SoeButton(
                                label: tr.whatsapp,
                                variant: SoeButtonVariant.outline,
                                size: SoeButtonSize.md,
                                onPressed: () =>
                                    unawaited(_copy(phone.whatsappUrl)),
                              ),
                            ],
                            SoeButton(
                              label: tr.emailButton,
                              variant: SoeButtonVariant.tertiary,
                              size: SoeButtonSize.md,
                              onPressed: () => unawaited(_copy(help.email)),
                            ),
                          ]),
                        ]),
                  ),
                  AccountCard(
                    soft: true,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AccountCardTitle(tr.emergency),
                          Text(
                              help.emergencyText.isNotEmpty
                                  ? help.emergencyText
                                  : tutor
                                      ? tr.emergencyTutor
                                      : tr.emergencyParent,
                              style: AppTypography.body
                                  .copyWith(color: AppPalette.text2)),
                          const SizedBox(height: 16),
                          SoeButton(
                            label: tr.reportEmergency,
                            variant: SoeButtonVariant.dangerOutline,
                            size: SoeButtonSize.md,
                            onPressed: () => unawaited(context
                                .push('${RouteNames.reportNew}?serious=1')),
                          ),
                        ]),
                  ),
                ]);
          },
        ),
      ],
    );
  }
}

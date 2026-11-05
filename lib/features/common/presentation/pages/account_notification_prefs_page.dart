import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';

/// COM-06 — categories × channels of the active role, saved at each tap (SMS and WhatsApp
/// shown, not yet available), and the messages always sent, locked and explained.
class AccountNotificationPrefsPage extends ConsumerStatefulWidget {
  const AccountNotificationPrefsPage({super.key});

  @override
  ConsumerState<AccountNotificationPrefsPage> createState() =>
      _AccountNotificationPrefsPageState();
}

class _AccountNotificationPrefsPageState
    extends ConsumerState<AccountNotificationPrefsPage> {
  /// The grid as last shown: changed at once on a tap, replaced by the server's answer.
  NotificationPreferences? _shown;
  DateTime? _savedAt;

  Future<void> _toggle(PreferenceCategory category, String channel) async {
    final before = _shown!;
    final value = !category.channel(channel);
    setState(() =>
        _shown = before.withCategory(category.withChannel(channel, value)));
    try {
      final saved = await ref
          .read(accountApiProvider)
          .updateNotificationPreference(
              category: category.key, channel: channel, value: value);
      if (mounted) {
        setState(() {
          _shown = saved;
          _savedAt = DateTime.now();
        });
      }
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _shown = before);
      SoeToast.show(context,
          message: accountFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.preferences;
    final value = ref.watch(notificationPreferencesProvider);
    return AccountScaffold(
      title: tr.crumbTitle,
      crumb: tr.crumb,
      children: [
        AccountPageTitle(tr.title, subtitle: tr.autosave),
        AccountAsync(
          value: value,
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
          builder: (loaded) {
            final prefs = _shown ?? loaded;
            return Column(children: [
              AccountCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AccountCardTitle(tr.grid,
                          trailing: _savedAt == null
                              ? null
                              : Text(
                                  tr.savedAt(
                                      time: AccountFormat.time(_savedAt!)),
                                  style: AppTypography.caption
                                      .copyWith(color: AppPalette.text2))),
                      _Grid(
                        prefs: prefs,
                        onToggle: (category, channel) {
                          _shown ??= loaded;
                          unawaited(_toggle(category, channel));
                        },
                      ),
                      if (prefs.channels.any((channel) => !channel.available))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(tr.soon,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
                        ),
                    ]),
              ),
              if (prefs.mandatory.isNotEmpty)
                AccountCard(
                  soft: true,
                  padding: EdgeInsets.zero,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: AccountCardTitle(tr.always),
                        ),
                        for (final message in prefs.mandatory)
                          AccountRow(
                            icon: Icons.lock_outline,
                            iconBackground: AppPalette.white,
                            title: message.title,
                            subtitle: message.text,
                            trailing: Text(tr.required,
                                style: AppTypography.labelSm
                                    .copyWith(color: AppPalette.text)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(tr.alwaysHelp,
                              style: AppTypography.caption
                                  .copyWith(color: AppPalette.text2)),
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

class _Grid extends StatelessWidget {
  const _Grid({required this.prefs, required this.onToggle});

  final NotificationPreferences prefs;
  final void Function(PreferenceCategory category, String channel) onToggle;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.preferences;
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.5)},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          const SizedBox.shrink(),
          for (final channel in prefs.channels)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              // One line, shrunk if the column is narrow (« WhatsApp » never breaks).
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(channel.label,
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption
                        .copyWith(color: AppPalette.text2)),
              ),
            ),
        ]),
        for (final category in prefs.categories)
          TableRow(children: [
            Text(category.label,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            for (final channel in prefs.channels)
              _Box(
                checked: channel.available && category.channel(channel.key),
                available: channel.available,
                label: tr.boxLabel(
                    category: category.label, channel: channel.label),
                onTap: channel.available
                    ? () => onToggle(category, channel.key)
                    : null,
              ),
          ]),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box(
      {required this.checked,
      required this.available,
      required this.label,
      this.onTap});

  final bool checked;
  final bool available;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        checked: checked,
        enabled: available,
        button: available,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 44,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: checked
                  ? AppPalette.teal500
                  : available
                      ? AppPalette.white
                      : AppPalette.n100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppPalette.border),
            ),
            child: checked
                ? const Icon(Icons.check, size: 16, color: AppPalette.white)
                : null,
          ),
        ),
      );
}

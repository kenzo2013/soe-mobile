import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/notification_preferences.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// 6 · Préférences de notification (design `CommonNotifPrefs`) — grille par
/// catégorie, un toggle par canal (email / web / push selon l'API),
/// sauvegarde automatique au changement.
class AccountNotificationPrefsPage extends ConsumerWidget {
  const AccountNotificationPrefsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final async = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.account.notificationPrefs.title,
        subtitle: tr.account.notificationPrefs.subtitle,
      ),
      body: async.when(
        // Garde la grille affichée pendant le re-fetch déclenché par un toggle
        // (sinon flash du spinner à chaque sauvegarde).
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
        data: (prefs) => prefs.categories.isEmpty
            ? Center(child: Text(tr.account.notificationPrefs.empty))
            : _PrefsGrid(initial: prefs),
      ),
    );
  }
}

String _channelLabel(Translations tr, String channel) => switch (channel) {
      'email' => tr.account.notificationPrefs.channelEmail,
      'web' => tr.account.notificationPrefs.channelWeb,
      'push' => tr.account.notificationPrefs.channelPush,
      _ => channel.toUpperCase(),
    };

class _PrefsGrid extends ConsumerStatefulWidget {
  const _PrefsGrid({required this.initial});
  final NotificationPreferences initial;

  @override
  ConsumerState<_PrefsGrid> createState() => _PrefsGridState();
}

class _PrefsGridState extends ConsumerState<_PrefsGrid> {
  late NotificationPreferences _prefs;
  bool _savedHint = false;

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial;
  }

  Future<void> _toggle(NotificationCategory cat, String channel) async {
    final tr = Translations.of(context);
    final previous = _prefs;
    final optimistic = _prefs.withUpdated(cat.toggle(channel));
    setState(() {
      _prefs = optimistic;
      _savedHint = false;
    });

    final r = await ref
        .read(commonRepositoryProvider)
        .updateNotificationPreferences(optimistic);

    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        // Synchronise avec l'état serveur + rafraîchit le provider partagé
        // (sous-titre du hub, et état correct au prochain accès).
        setState(() {
          _prefs = value;
          _savedHint = true;
        });
        ref.invalidate(notificationPreferencesProvider);
      case Err():
        setState(() => _prefs = previous); // revert
        SoeToast.show(
          context,
          message: tr.account.notificationPrefs.saveFailed,
          tone: SoeToastTone.danger,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final channels = _prefs.channels;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En-tête de colonnes
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tr.account.notificationPrefs.categoryHeader,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.n700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              for (final ch in channels)
                SizedBox(
                  width: 48,
                  child: Text(
                    _channelLabel(tr, ch),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.n700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.n300),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _prefs.categories.length; i++)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == _prefs.categories.length - 1
                            ? Colors.transparent
                            : AppPalette.n300,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _prefs.categories[i].label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.ink,
                              ),
                            ),
                            if (_prefs.categories[i].sub.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _prefs.categories[i].sub,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppPalette.n700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      for (final ch in channels)
                        SizedBox(
                          width: 48,
                          child: Center(
                            child: _Toggle(
                              on: _prefs.categories[i].isOn(ch),
                              onTap: () =>
                                  _toggle(_prefs.categories[i], ch),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_savedHint) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppPalette.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 14, color: AppPalette.success),
                    const SizedBox(width: 6),
                    Text(
                      tr.account.notificationPrefs.savedHint,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.on, required this.onTap});
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 36,
        height: 22,
        decoration: BoxDecoration(
          color: on ? AppPalette.success : AppPalette.n300,
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: on ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }
}

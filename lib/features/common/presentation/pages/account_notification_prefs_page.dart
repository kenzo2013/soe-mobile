import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../domain/entities/notification_preferences.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// 6 · Préférences de notification (design `CommonNotifPrefs`) — grille par
/// catégorie, un toggle par canal (email / web / push selon l'API),
/// sauvegarde automatique au changement.
class AccountNotificationPrefsPage extends ConsumerWidget {
  const AccountNotificationPrefsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationPreferencesProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: const CommonTopBar(
        title: 'Préférences de notification',
        subtitle: 'Sauvegarde automatique',
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(notificationPreferencesProvider),
        ),
        data: (prefs) => prefs.categories.isEmpty
            ? const Center(child: Text('Aucune catégorie disponible'))
            : _PrefsGrid(initial: prefs),
      ),
    );
  }
}

const _channelLabels = {'email': 'EMAIL', 'web': 'WEB', 'push': 'PUSH'};

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
    final previous = _prefs;
    final updated = _prefs.withUpdated(cat.toggle(channel));
    setState(() {
      _prefs = updated;
      _savedHint = false;
    });

    final ok = await ref
        .read(commonActionViewModelProvider('prefs').notifier)
        .run(() async {
      final r = await ref
          .read(commonRepositoryProvider)
          .updateNotificationPreferences(updated);
      return switch (r) {
        Ok() => const Ok<void, Failure>(null),
        Err(:final failure) => Err<void, Failure>(failure),
      };
    });

    if (!mounted) return;
    if (ok) {
      setState(() => _savedHint = true);
    } else {
      setState(() => _prefs = previous); // revert
      SoeToast.show(
        context,
        message: 'Échec de la sauvegarde',
        tone: SoeToastTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final channels = _prefs.channels;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // En-tête de colonnes
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'CATÉGORIE',
                  style: TextStyle(
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
                    _channelLabels[ch] ?? ch.toUpperCase(),
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
                  children: const [
                    Icon(Icons.check, size: 14, color: AppPalette.success),
                    SizedBox(width: 6),
                    Text(
                      'Modifications enregistrées',
                      style: TextStyle(
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

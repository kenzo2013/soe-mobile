import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_alert.dart';
import '../../../../core/widgets/soe_badge.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_otp_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_money_api.dart';
import '../../data/tutor_money_models.dart';
import '../providers.dart';
import '../tutor_money_providers.dart';
import '../widgets/tutor_panel.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';

/// REP-20 — the payout methods (MTN MoMo, Orange Money, bank; one by default). Every change asks
/// for the password again, then a 6-digit code sent by e-mail confirms it.
class TutorPayoutMethodsPage extends ConsumerWidget {
  const TutorPayoutMethodsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.payout;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(
          section: Translations.of(context).shell.more.tab, title: tr.title),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tutorPayoutMethodsProvider.future),
        child: TutorAsyncBody<List<TutorPayoutMethod>>(
          value: ref.watch(tutorPayoutMethodsProvider),
          onRetry: () => ref.invalidate(tutorPayoutMethodsProvider),
          builder: (methods) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(tr.title, style: AppTypography.h1),
              const SizedBox(height: 4),
              Text(tr.intro,
                  style: AppTypography.body.copyWith(color: AppPalette.text2)),
              const SizedBox(height: 16),
              if (methods.isEmpty)
                SoeEmptyState(
                    title: tr.empty,
                    message: tr.emptyText,
                    icon: Icons.account_balance_wallet_outlined)
              else
                TutorPanel(
                  children: methods
                      .map((method) => TutorPanelRow(
                            icon: method.isMobile
                                ? Icons.account_balance_wallet_outlined
                                : Icons.credit_card_outlined,
                            title: method.name,
                            subtitle: method.detail,
                            trailing: method.isDefault
                                ? SoeBadge(
                                    label: tr.defaultBadge,
                                    tone: SoeBadgeTone.success)
                                : null,
                            onTap: () => unawaited(
                                _showActions(context, ref, method, methods)),
                          ))
                      .toList(),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: AppPalette.n50, borderRadius: AppRadius.rMd),
                alignment: Alignment.centerLeft,
                child: SoeButton(
                  label: tr.add,
                  icon: Icons.add,
                  variant: SoeButtonVariant.outline,
                  size: SoeButtonSize.md,
                  onPressed: () => unawaited(_showAdd(context, ref, methods)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showAdd(BuildContext context, WidgetRef ref,
    List<TutorPayoutMethod> methods) async {
  final tr = Translations.of(context).tutorSpace.payout;
  final kind = await showModalBottomSheet<TutorPayoutChangeKind>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined,
              color: AppPalette.teal500),
          title: Text(tr.addMobile, style: AppTypography.label),
          onTap: () => Navigator.pop(sheet, TutorPayoutChangeKind.addMobile),
        ),
        ListTile(
          leading:
              const Icon(Icons.credit_card_outlined, color: AppPalette.teal500),
          title: Text(tr.addBank, style: AppTypography.label),
          onTap: () => Navigator.pop(sheet, TutorPayoutChangeKind.addBank),
        ),
      ]),
    ),
  );
  if (kind != null && context.mounted) {
    await _startChange(context, ref, kind, null, methods);
  }
}

Future<void> _showActions(BuildContext context, WidgetRef ref,
    TutorPayoutMethod method, List<TutorPayoutMethod> methods) async {
  final tr = Translations.of(context).tutorSpace.payout;
  final kind = await showModalBottomSheet<TutorPayoutChangeKind>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('${method.name} · ${method.detail}',
              style: AppTypography.title),
        ),
        if (method.canBeDefault)
          ListTile(
            leading: const Icon(Icons.check_circle_outline,
                color: AppPalette.teal500),
            title: Text(tr.makeDefault, style: AppTypography.label),
            onTap: () =>
                Navigator.pop(sheet, TutorPayoutChangeKind.makeDefault),
          ),
        ListTile(
          leading: const Icon(Icons.edit_outlined, color: AppPalette.teal500),
          title: Text(method.isMobile ? tr.replaceMobile : tr.replaceBank,
              style: AppTypography.label),
          onTap: () => Navigator.pop(
              sheet,
              method.isMobile
                  ? TutorPayoutChangeKind.replaceMobile
                  : TutorPayoutChangeKind.replaceBank),
        ),
        ListTile(
          leading:
              const Icon(Icons.delete_outline, color: AppPalette.dangerText),
          title: Text(tr.remove,
              style:
                  AppTypography.label.copyWith(color: AppPalette.dangerText)),
          onTap: () => Navigator.pop(sheet, TutorPayoutChangeKind.remove),
        ),
      ]),
    ),
  );
  if (kind != null && context.mounted) {
    await _startChange(context, ref, kind, method, methods);
  }
}

/// The details and the password, then the code; the list is read again once confirmed.
Future<void> _startChange(
  BuildContext context,
  WidgetRef ref,
  TutorPayoutChangeKind kind,
  TutorPayoutMethod? method,
  List<TutorPayoutMethod> methods,
) async {
  final change = await showModalBottomSheet<TutorPayoutMethodChange>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        TutorPayoutChangeSheet(kind: kind, method: method, methods: methods),
  );
  if (change == null || !context.mounted) return;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    isDismissible: false,
    builder: (_) => TutorPayoutCodeSheet(change: change),
  );
  ref
    ..invalidate(tutorPayoutMethodsProvider)
    ..invalidate(tutorEarningsProvider);
  if (confirmed == true && context.mounted) {
    SoeToast.show(context,
        message: Translations.of(context).tutorSpace.payout.confirmed,
        tone: SoeToastTone.success);
  }
}

/// The form of a change: the details of the [kind] and the password; pops the change asked for.
class TutorPayoutChangeSheet extends ConsumerStatefulWidget {
  const TutorPayoutChangeSheet({
    super.key,
    required this.kind,
    required this.methods,
    this.method,
  });

  final TutorPayoutChangeKind kind;
  final TutorPayoutMethod? method;
  final List<TutorPayoutMethod> methods;

  @override
  ConsumerState<TutorPayoutChangeSheet> createState() =>
      _TutorPayoutChangeSheetState();
}

class _TutorPayoutChangeSheetState
    extends ConsumerState<TutorPayoutChangeSheet> {
  static const _bankFields = [
    'account_holder',
    'bank_name',
    'account_number',
    'iban',
    'bic',
    'key',
  ];

  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _bank = {
    for (final field in _bankFields) field: TextEditingController()
  };
  String? _operator;
  int? _replacementId;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _operator = widget.method?.operator;
  }

  @override
  void dispose() {
    _password.dispose();
    _phone.dispose();
    for (final controller in _bank.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TutorPayoutChangeKind get _kind => widget.kind;

  /// A default account is removed only with another Mobile Money account to take its place.
  List<TutorPayoutMethod> get _replacements => widget.methods
      .where((m) => m.isMobile && m.id != widget.method?.id)
      .toList();

  bool get _needsReplacement =>
      _kind == TutorPayoutChangeKind.remove && widget.method?.isDefault == true;

  bool get _blocked => _needsReplacement && _replacements.isEmpty;

  bool get _complete {
    if (_password.text.isEmpty) return false;
    if (_kind.needsMobile) {
      return _operator != null && _phone.text.trim().isNotEmpty;
    }
    if (_kind.needsBank) {
      return _bank.values.every((c) => c.text.trim().isNotEmpty);
    }
    if (_needsReplacement) return _replacementId != null;
    return true;
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final change = await ref.read(tutorMoneyApiProvider).requestPayoutChange(
            TutorPayoutChangeRequest(
              kind: _kind,
              currentPassword: _password.text,
              methodId: widget.method?.id,
              replacementId: _needsReplacement ? _replacementId : null,
              operator: _operator,
              phone: _phone.text.trim(),
              bank: {
                for (final entry in _bank.entries)
                  entry.key: entry.value.text.trim()
              },
            ),
          );
      if (mounted) Navigator.pop(context, change);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = tutorFailureMessage(context, failure);
      });
    }
  }

  String _title(TranslationsTutorSpacePayoutFr tr) => switch (_kind) {
        TutorPayoutChangeKind.addMobile => tr.addMobile,
        TutorPayoutChangeKind.addBank => tr.addBank,
        TutorPayoutChangeKind.replaceMobile => tr.replaceMobile,
        TutorPayoutChangeKind.replaceBank => tr.replaceBank,
        TutorPayoutChangeKind.remove => tr.remove,
        TutorPayoutChangeKind.makeDefault => tr.makeDefault,
      };

  String _bankLabel(TranslationsTutorSpacePayoutFr tr, String field) =>
      switch (field) {
        'account_holder' => tr.accountHolder,
        'bank_name' => tr.bankName,
        'account_number' => tr.accountNumber,
        'iban' => tr.iban,
        'bic' => tr.bic,
        _ => tr.key,
      };

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.payout;
    final method = widget.method;
    void refresh(String _) => setState(() {});
    return TutorSheet(children: [
      Text(_title(tr), style: AppTypography.h3),
      if (method != null) ...[
        const SizedBox(height: 4),
        Text('${method.name} · ${method.detail}',
            style: AppTypography.body.copyWith(color: AppPalette.text2)),
      ],
      const SizedBox(height: 16),
      if (_kind.needsMobile) ...[
        Text(tr.operator, style: AppTypography.label),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          for (final operator in const ['mtn', 'orange'])
            SoeChip(
              label: operator == 'mtn' ? tr.operators.mtn : tr.operators.orange,
              selected: _operator == operator,
              onTap: () => setState(() => _operator = operator),
            ),
        ]),
        const SizedBox(height: 16),
        SoeTextField(
          controller: _phone,
          label: tr.phone,
          hint: tr.phoneHint,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))
          ],
          onChanged: refresh,
        ),
        const SizedBox(height: 4),
        Text(tr.phoneHelp,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 16),
      ],
      if (_kind.needsBank)
        for (final field in _bankFields) ...[
          SoeTextField(
            controller: _bank[field]!,
            label: _bankLabel(tr, field),
            onChanged: refresh,
          ),
          const SizedBox(height: 12),
        ],
      if (_kind == TutorPayoutChangeKind.remove) ...[
        Text(tr.removeNote,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: 16),
        if (_blocked)
          SoeAlert(
              title: tr.replacement,
              body: tr.replacementMissing,
              tone: SoeAlertTone.warning)
        else if (_needsReplacement) ...[
          Text(tr.replacement, style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final replacement in _replacements)
              SoeChip(
                label: '${replacement.name} · ${replacement.detail}',
                selected: _replacementId == replacement.id,
                onTap: () => setState(() => _replacementId = replacement.id),
              ),
          ]),
          const SizedBox(height: 16),
        ],
      ],
      if (!_blocked) ...[
        SoePasswordField(
          controller: _password,
          label: tr.password,
          textInputAction: TextInputAction.done,
        ),
        // SoePasswordField has no onChanged: the button follows the controller.
        ListenableBuilder(
          listenable: _password,
          builder: (context, _) =>
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 8),
            Text(tr.codeNote,
                style: AppTypography.caption.copyWith(color: AppPalette.text2)),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: AppTypography.bodySm
                      .copyWith(color: AppPalette.dangerText)),
            ],
            const SizedBox(height: 16),
            SoeButton(
              label: tr.sendCode,
              fullWidth: true,
              loading: _busy,
              variant: _kind == TutorPayoutChangeKind.remove
                  ? SoeButtonVariant.danger
                  : SoeButtonVariant.primary,
              onPressed:
                  _busy || !_complete ? null : () => unawaited(_submit()),
            ),
          ]),
        ),
      ],
    ]);
  }
}

/// REP-20 « Confirmation par code »: the 6-digit code sent by e-mail; pops true once applied.
class TutorPayoutCodeSheet extends ConsumerStatefulWidget {
  const TutorPayoutCodeSheet({super.key, required this.change});

  final TutorPayoutMethodChange change;

  @override
  ConsumerState<TutorPayoutCodeSheet> createState() =>
      _TutorPayoutCodeSheetState();
}

class _TutorPayoutCodeSheetState extends ConsumerState<TutorPayoutCodeSheet> {
  String _code = '';
  String? _error;

  /// Expired, locked or conflicting: the request must start again, the code is useless.
  bool _over = false;
  bool _busy = false;
  int _attempt = 0;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(tutorMoneyApiProvider)
          .confirmPayoutChange(widget.change.id, _code);
      if (mounted) Navigator.pop(context, true);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = tutorFailureMessage(context, failure);
        _over = switch (failure) {
          CodeFailure(problem: CodeProblem.invalid) => false,
          RateLimitedFailure() => false,
          NetworkFailure() || TimeoutFailure() => false,
          _ => true,
        };
        // A wrong code empties the boxes for a new try.
        _attempt++;
        _code = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.payout;
    final expiresAt = widget.change.expiresAt;
    return TutorSheet(children: [
      Row(children: [
        Expanded(child: Text(tr.confirmTitle, style: AppTypography.h2)),
        IconButton(
          tooltip: tr.cancel,
          onPressed: () => Navigator.pop(context, false),
          icon: const Icon(Icons.close),
        ),
      ]),
      const SizedBox(height: 4),
      Text(tr.confirmIntro(summary: widget.change.summary),
          style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
      const SizedBox(height: 16),
      Text(tr.code, style: AppTypography.label),
      const SizedBox(height: 8),
      SoeOtpField(
        key: ValueKey(_attempt),
        enabled: !_over && !_busy,
        errorText: _error,
        onChanged: (value) => setState(() => _code = value),
      ),
      if (expiresAt != null) ...[
        const SizedBox(height: 8),
        Text(tr.validUntil(time: TutorFormat.time(expiresAt)),
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      ],
      const SizedBox(height: 16),
      SoeButton(
        label: tr.confirm,
        fullWidth: true,
        variant: SoeButtonVariant.secondary,
        loading: _busy,
        onPressed: _busy || _over || !RegExp(r'^\d{6}$').hasMatch(_code)
            ? null
            : () => unawaited(_confirm()),
      ),
      const SizedBox(height: 8),
      SoeButton(
        label: tr.cancel,
        fullWidth: true,
        variant: SoeButtonVariant.tertiary,
        onPressed: () => Navigator.pop(context, false),
      ),
    ]);
  }
}

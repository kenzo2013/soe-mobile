import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_adaptive_panel.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_dialog.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/parent_models.dart';
import '../providers.dart';
import 'parent_ui.dart';

/// « Faire payer quelqu'un d'autre » — the secondary action of an unpaid invoice (holder only).
class PaymentLinkAction extends StatelessWidget {
  const PaymentLinkAction({super.key, required this.invoice});

  final ParentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    if (!invoice.canShareLink) return const SizedBox.shrink();
    return SoeButton(
      label: Translations.of(context).parentSpace.paymentLink.action,
      icon: Icons.ios_share,
      variant: SoeButtonVariant.outline,
      fullWidth: true,
      onPressed: () => unawaited(showPaymentLinkPanel(context, invoice)),
    );
  }
}

/// Opens the payment link of [invoice]: a bottom sheet on a phone, a dialog on a tablet.
Future<void> showPaymentLinkPanel(
        BuildContext context, ParentInvoice invoice) =>
    showSoeAdaptivePanel<void>(context,
        builder: (_) => PaymentLinkPanel(invoice: invoice));

/// The link, its state and expiry, and what can be done with it: share, copy, renew, deactivate.
/// The link is created on opening when there is none usable yet.
class PaymentLinkPanel extends ConsumerStatefulWidget {
  const PaymentLinkPanel({super.key, required this.invoice});

  final ParentInvoice invoice;

  @override
  ConsumerState<PaymentLinkPanel> createState() => _PaymentLinkPanelState();
}

class _PaymentLinkPanelState extends ConsumerState<PaymentLinkPanel> {
  bool _busy = false;

  PaymentLinkNotifier get _notifier =>
      ref.read(paymentLinkProvider(widget.invoice.id).notifier);

  @override
  void initState() {
    super.initState();
    // The first opening creates the link: the parent came to send one.
    unawaited(Future.microtask(() async {
      final current =
          await ref.read(paymentLinkProvider(widget.invoice.id).future);
      if (current == null || !current.usable) await _run(_notifier.ensure);
    }).catchError((Object _) {}));
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    if (_busy) return null;
    setState(() => _busy = true);
    try {
      return await action();
    } on Failure catch (failure) {
      if (mounted)
        SoeToast.show(context,
            message: parentFailureMessage(context, failure),
            tone: SoeToastTone.danger);
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(PaymentLink link) {
    final tr = Translations.of(context).parentSpace.paymentLink;
    return tr.message(
        month: _month(),
        amount: ParentFormat.amount(context, widget.invoice.balanceDue),
        url: link.url);
  }

  String _month() =>
      DateFormat.yMMMM(Localizations.localeOf(context).languageCode)
          .format(widget.invoice.period);

  Future<void> _share(PaymentLink link) =>
      _run(() => ref.read(shareServiceProvider).share(_message(link),
          subject: Translations.of(context)
              .parentSpace
              .paymentLink
              .subject(month: _month())));

  Future<void> _copy(PaymentLink link) async {
    await _run(() => ref.read(shareServiceProvider).copy(link.url));
    if (mounted)
      SoeToast.show(context,
          message: Translations.of(context).parentSpace.paymentLink.copied);
  }

  Future<void> _regenerate() async {
    final tr = Translations.of(context).parentSpace.paymentLink;
    final ok = await SoeConfirmDialog.show(context,
            title: tr.regenerateTitle,
            message: tr.regenerateText,
            confirmLabel: tr.regenerate) ??
        false;
    if (ok) await _run(_notifier.regenerate);
  }

  Future<void> _revoke() async {
    final tr = Translations.of(context).parentSpace.paymentLink;
    final ok = await SoeConfirmDialog.show(context,
            title: tr.revokeTitle,
            message: tr.revokeText,
            confirmLabel: tr.revoke,
            destructive: true) ??
        false;
    if (!ok) return;
    await _run(_notifier.revoke);
    if (mounted) SoeToast.show(context, message: tr.revoked);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.paymentLink;
    final value = ref.watch(paymentLinkProvider(widget.invoice.id));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr.title, style: AppTypography.h3),
        const SizedBox(height: AppSpacing.xs),
        Text(
            '${_month()} · ${ParentFormat.amount(context, widget.invoice.balanceDue)}',
            style: AppTypography.label.copyWith(color: AppPalette.teal800)),
        const SizedBox(height: AppSpacing.md),
        Text(tr.lead,
            style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
        const SizedBox(height: AppSpacing.lg),
        value.when(
          loading: () => const SoeSkeleton(height: 120),
          error: (error, _) => ErrorView(
              failure: asFailure(error),
              onRetry: () =>
                  ref.invalidate(paymentLinkProvider(widget.invoice.id))),
          data: (link) => link == null || !link.usable
              ? _Empty(busy: _busy, onCreate: () => _run(_notifier.ensure))
              : _Link(
                  link: link,
                  busy: _busy,
                  onShare: () => _share(link),
                  onCopy: () => _copy(link),
                  onRegenerate: _regenerate,
                  onRevoke: _revoke),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.busy, required this.onCreate});

  final bool busy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.paymentLink;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(tr.none, style: AppTypography.bodySm),
      const SizedBox(height: AppSpacing.md),
      SoeButton(
          label: tr.create,
          fullWidth: true,
          loading: busy,
          onPressed: onCreate),
    ]);
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.link,
    required this.busy,
    required this.onShare,
    required this.onCopy,
    required this.onRegenerate,
    required this.onRevoke,
  });

  final PaymentLink link;
  final bool busy;
  final VoidCallback onShare;
  final VoidCallback onCopy;
  final VoidCallback onRegenerate;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).parentSpace.paymentLink;
    final expires = link.expiresAt;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
            color: AppPalette.n50, borderRadius: AppRadius.rSm),
        child: SelectableText(link.url,
            maxLines: 2,
            style: AppTypography.bodySm.copyWith(color: AppPalette.teal800)),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
          [
            _statusLabel(context, link.status),
            if (expires != null)
              tr.expires(date: ParentFormat.dayLong(context, expires)),
          ].join(' · '),
          style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      const SizedBox(height: AppSpacing.lg),
      SoeButton(
          label: tr.share,
          icon: Icons.ios_share,
          fullWidth: true,
          loading: busy,
          onPressed: busy ? null : onShare),
      const SizedBox(height: AppSpacing.sm),
      SoeButton(
          label: tr.copy,
          icon: Icons.copy_outlined,
          variant: SoeButtonVariant.outline,
          fullWidth: true,
          onPressed: busy ? null : onCopy),
      const SizedBox(height: AppSpacing.xs),
      Wrap(alignment: WrapAlignment.spaceBetween, children: [
        SoeButton(
            label: tr.regenerate,
            variant: SoeButtonVariant.tertiary,
            onPressed: busy ? null : onRegenerate),
        SoeButton(
            label: tr.revoke,
            variant: SoeButtonVariant.tertiary,
            onPressed: busy ? null : onRevoke),
      ]),
    ]);
  }

  static String _statusLabel(BuildContext context, PaymentLinkStatus status) {
    final tr = Translations.of(context).parentSpace.paymentLink.status;
    return switch (status) {
      PaymentLinkStatus.active => tr.active,
      PaymentLinkStatus.opened => tr.opened,
      PaymentLinkStatus.paid => tr.paid,
      PaymentLinkStatus.expired => tr.expired,
      PaymentLinkStatus.revoked => tr.revoked,
    };
  }
}

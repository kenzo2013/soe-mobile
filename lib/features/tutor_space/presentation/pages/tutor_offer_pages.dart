import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/paginated.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_chip.dart';
import '../../../../core/widgets/soe_empty_state.dart';
import '../../../../core/widgets/soe_skeleton.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../data/tutor_offer_models.dart';
import '../../data/tutor_references.dart';
import '../tutor_offer_providers.dart';
import '../tutor_space_routes.dart';
import '../widgets/tutor_offer_ui.dart';
import '../widgets/tutor_ui.dart';
import '../../../common/presentation/widgets/space_app_bar.dart';
import '../../../common/presentation/widgets/tab_top_bar.dart';
import '../tutor_navigation.dart';

/// REP-10 — the offers SOE publishes, filtered by the tutor's subjects, their city and a class,
/// a page at a time (« load more »).
class TutorOffersPage extends ConsumerStatefulWidget {
  const TutorOffersPage({super.key});

  @override
  ConsumerState<TutorOffersPage> createState() => _TutorOffersPageState();
}

class _TutorOffersPageState extends ConsumerState<TutorOffersPage> {
  TutorOfferFilters _filters = const TutorOfferFilters();
  int _pages = 1;

  void _filter(TutorOfferFilters filters) => setState(() {
        _filters = filters;
        _pages = 1;
      });

  Future<void> _refresh() async {
    setState(() => _pages = 1);
    ref.invalidate(tutorOffersPageProvider);
    await ref
        .read(tutorOffersPageProvider(TutorOfferPageKey(_filters, 1)).future);
  }

  Future<void> _chooseClass() async {
    final tr = Translations.of(context).tutorSpace.offers.filters;
    final classes =
        ref.read(tutorReferencesProvider).valueOrNull?.schoolClasses ??
            const <TutorReference>[];
    final chosen = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListView(shrinkWrap: true, children: [
            ListTile(
              title: Text(tr.allClasses),
              trailing: _filters.schoolClassId == null
                  ? const Icon(Icons.check, color: AppPalette.teal)
                  : null,
              onTap: () => Navigator.of(context).pop(0),
            ),
            for (final schoolClass in classes)
              ListTile(
                title: Text(schoolClass.name),
                trailing: _filters.schoolClassId == schoolClass.id
                    ? const Icon(Icons.check, color: AppPalette.teal)
                    : null,
                onTap: () => Navigator.of(context).pop(schoolClass.id),
              ),
          ]),
        ),
      ),
    );
    if (chosen == null || !mounted) return;
    _filter(
        _filters.copyWith(schoolClassId: () => chosen == 0 ? null : chosen));
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.offers;
    final references = ref.watch(tutorReferencesProvider).valueOrNull;
    final classId = _filters.schoolClassId;
    final className = classId == null
        ? null
        : references?.schoolClasses
            .where((c) => c.id == classId)
            .map((c) => c.name)
            .firstOrNull;
    final first =
        ref.watch(tutorOffersPageProvider(TutorOfferPageKey(_filters, 1)));
    final root = !Navigator.of(context).canPop();
    return SpaceScreen(
      section: tutorMoreSection(context),
      title: tr.title,
      subtitle: tr.intro,
      onRefresh: _refresh,
      children: [
        if (!root) ...[
          Text(tr.intro,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 12),
        ],
        TutorInfoBanner(title: tr.applyBeforeValidation),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          SoeChip(
            label: tr.filters.mine,
            selected: _filters.mine,
            onTap: () => _filter(_filters.copyWith(mine: !_filters.mine)),
          ),
          SoeChip(
            label: tr.filters.zone,
            selected: _filters.zone,
            onTap: () => _filter(_filters.copyWith(zone: !_filters.zone)),
          ),
          SoeChip(
            label: className ?? tr.filters.schoolClass,
            selected: classId != null,
            onTap: references == null ? null : () => unawaited(_chooseClass()),
          ),
        ]),
        const SizedBox(height: 12),
        ...first.when(
          loading: () => const [
            SoeSkeleton(height: 160),
            SizedBox(height: 12),
            SoeSkeleton(height: 160),
          ],
          error: (error, _) => [
            SoeEmptyState(
              title: tutorFailureMessage(context, asFailure(error)),
              message: '',
              icon: Icons.cloud_off_outlined,
              actionLabel: Translations.of(context).common.retry,
              onAction: () => ref.invalidate(tutorOffersPageProvider),
            ),
          ],
          data: (page) => page.items.isEmpty
              ? [
                  SoeEmptyState(
                    title: tr.empty,
                    message: tr.emptyText,
                    icon: Icons.work_outline,
                    actionLabel: _filters.zone ? tr.changeZone : null,
                    onAction: () => unawaited(
                        context.push(TutorSpaceRoutes.fileSection('address'))),
                  ),
                ]
              : [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(tr.count(n: page.totalCount),
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ),
                  const SizedBox(height: 8),
                  for (var p = 1; p <= _pages; p++)
                    _OffersPage(
                      pageKey: TutorOfferPageKey(_filters, p),
                      last: p == _pages,
                      onMore: () => setState(() => _pages++),
                    ),
                ],
        ),
      ],
    );
  }
}

/// One page of offers; the last one shows « load more » while the server has more.
class _OffersPage extends ConsumerWidget {
  const _OffersPage(
      {required this.pageKey, required this.last, required this.onMore});

  final TutorOfferPageKey pageKey;
  final bool last;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.offers;
    final AsyncValue<Paginated<TutorOffer>> value =
        ref.watch(tutorOffersPageProvider(pageKey));
    return value.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SoeButton(
          label: Translations.of(context).common.retry,
          variant: SoeButtonVariant.tertiary,
          size: SoeButtonSize.md,
          fullWidth: true,
          onPressed: () => ref.invalidate(tutorOffersPageProvider(pageKey)),
        ),
      ),
      data: (page) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // A grid of two on a tablet.
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 640 ? 2 : 1;
          final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
          return Wrap(spacing: 12, children: [
            for (final offer in page.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: width,
                  child: TutorOfferCard(
                    offer: offer,
                    onTap: () => openTutorScreen(
                        context, TutorSpaceRoutes.offer(offer.id)),
                  ),
                ),
              ),
          ]);
        }),
        if (last && page.hasMore)
          SoeButton(
            label: tr.loadMore,
            variant: SoeButtonVariant.tertiary,
            size: SoeButtonSize.md,
            fullWidth: true,
            onPressed: onMore,
          ),
      ]),
    );
  }
}

/// REP-11 — an offer and the application, with an optional message to SOE; already applied;
/// sent. Opened with `?from=site` (the offer chosen on the website, VIT-07), it says so.
class TutorOfferPage extends ConsumerStatefulWidget {
  const TutorOfferPage({super.key, required this.offerId});

  final int offerId;

  @override
  ConsumerState<TutorOfferPage> createState() => _TutorOfferPageState();
}

class _TutorOfferPageState extends ConsumerState<TutorOfferPage> {
  /// The message limit of the server (Candidacy::MESSAGE_MAX).
  static const int _messageMax = 300;

  final _message = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  bool get _fromSite =>
      GoRouter.maybeOf(context)
          ?.routeInformationProvider
          .value
          .uri
          .queryParameters['from'] ==
      'site';

  Future<void> _apply() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(tutorOfferApiProvider)
          .apply(widget.offerId, message: _message.text);
      if (!mounted) return;
      setState(() => _sent = true);
      refreshTutorApplication(ref, widget.offerId);
    } on ValidationFailure catch (failure) {
      if (mounted)
        setState(() => _error = tutorFailureMessage(context, failure));
    } on Failure catch (failure) {
      if (!mounted) return;
      SoeToast.show(context,
          message: tutorFailureMessage(context, failure),
          tone: SoeToastTone.danger);
      if (failure is ConflictFailure) {
        ref.invalidate(tutorOfferProvider(widget.offerId));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.offers.detail;
    final value = ref.watch(tutorOfferProvider(widget.offerId));
    final offer = value.valueOrNull;
    final canApply = !_sent && (offer?.canApply ?? false);
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      appBar: SpaceAppBar(section: tutorMoreSection(context), title: tr.title),
      body: _sent
          ? _SentView(offerId: widget.offerId)
          : TutorAsyncBody<TutorOffer>(
              value: value,
              onRetry: () => ref.invalidate(tutorOfferProvider(widget.offerId)),
              builder: _details,
            ),
      bottomNavigationBar: canApply
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: AppPalette.white,
                  border: Border(top: BorderSide(color: AppPalette.border)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(tr.oneApplication,
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.text2)),
                  const SizedBox(height: 8),
                  SoeButton(
                    label: tr.apply,
                    loading: _busy,
                    loadingLabel: tr.applying,
                    fullWidth: true,
                    onPressed: _busy ? null : () => unawaited(_apply()),
                  ),
                ]),
              ),
            )
          : null,
    );
  }

  Widget _details(TutorOffer offer) {
    final tr = Translations.of(context).tutorSpace.offers;
    final rate = offer.sessionRate;
    final published = offer.publishedAt == null
        ? offer.reference
        : tr.detail.published(
            reference: offer.reference,
            date: TutorFormat.day(context, offer.publishedAt!));
    final rows = <(String, String)>[
      if (offer.neighborhood != null)
        (tr.detail.neighborhood, offer.neighborhood!),
      if (offer.startDate != null)
        (tr.detail.start, TutorFormat.dayLong(context, offer.startDate!)),
      if (offer.schoolClasses.isNotEmpty)
        (tr.detail.schoolClass, offer.schoolClasses.join(', ')),
    ];
    return RefreshIndicator(
      onRefresh: () => ref.refresh(tutorOfferProvider(widget.offerId).future),
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text(published.toUpperCase(),
            style: AppTypography.overline.copyWith(color: AppPalette.teal500)),
        const SizedBox(height: 4),
        Text(offer.title(tr.and),
            style: AppTypography.h2.copyWith(color: AppPalette.teal800)),
        if (offer.description.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(offer.description,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
        ],
        const SizedBox(height: 16),
        if (offer.applied && !offer.canApply) ...[
          _AlreadyApplied(offer: offer),
          const SizedBox(height: 12),
        ] else if (_fromSite) ...[
          TutorInfoBanner(
              icon: Icons.check,
              title: tr.detail.fromSite,
              body: tr.detail.fromSiteText),
          const SizedBox(height: 12),
        ],
        SoeCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(tr.detail.offer,
                style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
            const SizedBox(height: 6),
            Text(tr.detail.privacy,
                style: AppTypography.bodySm.copyWith(color: AppPalette.text2)),
            const SizedBox(height: 4),
            for (var i = 0; i < rows.length; i++)
              TutorInfoRow(
                  label: rows[i].$1,
                  value: rows[i].$2,
                  last: i == rows.length - 1),
          ]),
        ),
        if (offer.canApply) ...[
          const SizedBox(height: 12),
          SoeCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(tr.detail.message,
                            style: AppTypography.label)),
                    Text(tr.detail.optional,
                        style: AppTypography.caption
                            .copyWith(color: AppPalette.text2)),
                  ]),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('offer-message'),
                    controller: _message,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: _messageMax,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      hintText: tr.detail.messageHint,
                      errorText: _error,
                      counterText: '${_message.text.length} / $_messageMax',
                    ),
                  ),
                ]),
          ),
        ],
        if (rate != null) ...[
          const SizedBox(height: 12),
          SoeCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tr.detail.pay,
                  style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
              const SizedBox(height: 8),
              Text(TutorFormat.amount(context, rate),
                  style: AppTypography.numberL
                      .copyWith(color: AppPalette.teal800)),
              Text(tr.detail.perValidatedSession,
                  style:
                      AppTypography.caption.copyWith(color: AppPalette.text2)),
            ]),
          ),
        ],
        const SizedBox(height: 24),
      ]),
    );
  }
}

/// « Vous avez déjà postulé le … » with a link to the applications (REP-11-2).
class _AlreadyApplied extends StatelessWidget {
  const _AlreadyApplied({required this.offer});

  final TutorOffer offer;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.offers.detail;
    return TutorInfoBanner(
      title: tr.already(
          date: offer.appliedAt == null
              ? ''
              : TutorFormat.dayLong(context, offer.appliedAt!)),
      body: tr.alreadyText,
      actionLabel: tr.see,
      onAction: () => openTutorScreen(context, TutorSpaceRoutes.applications),
    );
  }
}

/// « Candidature envoyée » (REP-11-3): complete the file, follow it in the applications.
class _SentView extends StatelessWidget {
  const _SentView({required this.offerId});

  final int offerId;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).tutorSpace.offers.detail;
    return ListView(padding: const EdgeInsets.all(16), children: [
      SoeCard(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: AppPalette.successBg, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 32, color: AppPalette.success),
          ),
          const SizedBox(height: 16),
          Text(tr.sent,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(color: AppPalette.teal800)),
          const SizedBox(height: 8),
          Text(tr.sentText,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppPalette.text2)),
          const SizedBox(height: 16),
          SoeButton(
            label: tr.completeFile,
            onPressed: () => openTutorScreen(context, TutorSpaceRoutes.file),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                openTutorScreen(context, TutorSpaceRoutes.applications),
            child: Text(tr.follow, textAlign: TextAlign.center),
          ),
        ]),
      ),
    ]);
  }
}

/// REP-12 — my applications and SOE's answer (sent, selected, not selected); a tap opens the
/// offer.
class TutorApplicationsPage extends ConsumerWidget {
  const TutorApplicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).tutorSpace.offers;
    final value = ref.watch(tutorApplicationsProvider);
    return SpaceScreen(
      section: tutorMoreSection(context),
      title: tr.applications.title,
      onRefresh: () => ref.refresh(tutorApplicationsProvider.future),
      children: value.when(
        loading: () => const [
          SoeSkeleton(height: 140, borderRadius: AppRadius.rCardLg),
        ],
        error: (error, _) => [
          SoeCard(
            raised: true,
            child: ErrorView(
                failure: asFailure(error),
                onRetry: () => ref.invalidate(tutorApplicationsProvider)),
          ),
        ],
        data: (applications) => [
          if (applications.isEmpty)
            SoeCard(
              raised: true,
              child: SoeEmptyState(
                title: tr.applications.empty,
                message: tr.applications.emptyText,
                icon: Icons.insert_drive_file_outlined,
                actionLabel: tr.applications.seeOffers,
                onAction: () =>
                    openTutorScreen(context, TutorSpaceRoutes.offers),
              ),
            )
          else
            TutorListCard(
              raised: true,
              note: applications.any((a) => a.status == 'selected')
                  ? tr.applications.selectedNote
                  : null,
              children: [
                for (final application in applications)
                  TutorListTile(
                    leading: const TutorTileLeading(icon: Icons.work_outline),
                    title: application.title(tr.and),
                    subtitle: [
                      application.neighborhood,
                      if (application.sentAt != null)
                        tr.applications.sentOn(
                            date:
                                TutorFormat.day(context, application.sentAt!)),
                    ].whereType<String>().join(' · '),
                    badge: TutorToneBadge(
                        state: application.status,
                        label: application.statusLabel),
                    onTap: () => openTutorScreen(
                        context, TutorSpaceRoutes.offer(application.offerId)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

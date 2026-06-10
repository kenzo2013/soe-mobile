import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/session_detail.dart';
import '../../domain/entities/session_summary.dart';
import '../providers.dart';

class ParentSessionDetailPage extends ConsumerWidget {
  const ParentSessionDetailPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final state = ref.watch(sessionDetailViewModelProvider(id));
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: AppBar(
        backgroundColor: AppPalette.n100,
        elevation: 0,
        title: Text(tr.parent.sessionDetail.title),
        titleTextStyle: const TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: AppPalette.ink),
      ),
      body: state.when(
        initial: () => const Center(child: CircularProgressIndicator()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (f) => ErrorView(
          failure: f,
          onRetry: () =>
              ref.read(sessionDetailViewModelProvider(id).notifier).load(id),
        ),
        loaded: (d) => _Body(detail: d),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.detail});
  final SessionDetail detail;
  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final dateLine = DateFormat('EEEE d MMMM · HH:mm', 'fr').format(detail.startAt);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        SoeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLine,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.n700,
                ),
              ),
              const SizedBox(height: 12),
              _row(tr.parent.sessionDetail.student, detail.childName),
              _row(tr.parent.sessionDetail.tutor, detail.tutorName),
              _row(
                tr.parent.sessionDetail.duration,
                tr.parent.sessionDetail.durationValue(
                  count: detail.durationMinutes,
                ),
              ),
              if (detail.location != null)
                _row(tr.parent.sessionDetail.location, detail.location!),
              _row(
                tr.parent.sessionDetail.status,
                _statusLabel(tr, detail.status),
                last: true,
              ),
            ],
          ),
        ),
        if (detail.report != null) ...[
          const SizedBox(height: 16),
          _sectionTitle(tr.parent.sessionDetail.tutorReport),
          SoeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.report!.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppPalette.ink,
                    height: 1.5,
                  ),
                ),
                if (detail.report!.rating != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppPalette.yellow,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${detail.report!.rating!.toStringAsFixed(1)} / 5',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.ink,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        if (detail.tasks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle(tr.parent.sessionDetail.homework),
          SoeCard(
            child: Column(
              children: [
                for (var i = 0; i < detail.tasks.length; i++) ...[
                  Row(
                    children: [
                      Icon(
                        detail.tasks[i].done
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: detail.tasks[i].done
                            ? AppPalette.success
                            : AppPalette.n500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          detail.tasks[i].title,
                          style: TextStyle(
                            fontSize: 13,
                            color: detail.tasks[i].done
                                ? AppPalette.n700
                                : AppPalette.ink,
                            decoration: detail.tasks[i].done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < detail.tasks.length - 1)
                    const Divider(height: 16, color: AppPalette.n100),
                ],
              ],
            ),
          ),
        ],
        if (detail.notes != null && detail.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _sectionTitle(tr.parent.sessionDetail.notes),
          SoeCard(
            child: Text(
              detail.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: AppPalette.ink,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 4),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.ink,
          ),
        ),
      );

  Widget _row(String k, String v, {bool last = false}) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                k,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.n700,
                ),
              ),
            ),
            Flexible(
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.ink,
                ),
              ),
            ),
          ],
        ),
      );

  String _statusLabel(Translations tr, SessionStatus s) => switch (s) {
        SessionStatus.pending => tr.parent.sessionDetail.statusPending,
        SessionStatus.completed => tr.parent.sessionDetail.statusCompleted,
        SessionStatus.approved => tr.parent.sessionDetail.statusApproved,
        SessionStatus.rejected => tr.parent.sessionDetail.statusRejected,
        SessionStatus.unknown => '—',
      };
}

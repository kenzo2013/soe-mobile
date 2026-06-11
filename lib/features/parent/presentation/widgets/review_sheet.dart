import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_rating_stars.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/parent_review.dart';
import '../providers.dart';

/// Ouvre le formulaire d'avis (note + commentaire) pour un tuteur donné,
/// `POST /parents/reviews`. Rafraîchit la liste Avis au succès.
Future<void> showReviewSheet(
  BuildContext context,
  WidgetRef ref, {
  required String tutorId,
  String? tutorName,
  List<String> subjectIds = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppPalette.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReviewSheet(
      tutorId: tutorId,
      tutorName: tutorName,
      subjectIds: subjectIds,
    ),
  );
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({
    required this.tutorId,
    required this.tutorName,
    required this.subjectIds,
  });
  final String tutorId;
  final String? tutorName;
  final List<String> subjectIds;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tr = Translations.of(context);
    if (_rating == 0) {
      SoeToast.show(context,
          message: tr.parent.reviews.pleaseRate, tone: SoeToastTone.warning);
      return;
    }
    setState(() => _submitting = true);
    final r = await ref.read(reviewsRepositoryProvider).create(
          ReviewParams(
            tutorId: widget.tutorId,
            rating: _rating,
            comment: _comment.text.trim(),
            subjectIds: widget.subjectIds,
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (r) {
      case Ok():
        SoeToast.show(context,
            message: tr.parent.reviews.posted, tone: SoeToastTone.success);
        unawaited(ref.read(reviewsListViewModelProvider(null).notifier).load());
        Navigator.of(context).pop();
      case Err():
        SoeToast.show(context,
            message: tr.errors.unknown, tone: SoeToastTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppPalette.n300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            tr.parent.reviews.formTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.ink,
            ),
          ),
          if (widget.tutorName != null && widget.tutorName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.tutorName!,
              style: const TextStyle(fontSize: 13, color: AppPalette.n700),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            tr.parent.reviews.ratingLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppPalette.n700,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SoeRatingStars(
              rating: _rating,
              size: 36,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 18),
          SoeTextField(
            controller: _comment,
            label: tr.parent.reviews.commentLabel,
            hint: tr.parent.reviews.commentHint,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          SoeButton(
            label: tr.parent.reviews.submit,
            fullWidth: true,
            loading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

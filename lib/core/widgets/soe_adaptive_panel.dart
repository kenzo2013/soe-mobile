import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Width from which a panel opens as a centred dialog instead of a bottom sheet (tablet).
const double soeTabletBreakpoint = 600;

/// The readable width of a panel or a form on a tablet.
const double soeReadableMaxWidth = 640;

/// Opens [builder] as a bottom sheet on a phone, as a centred dialog at most
/// [soeReadableMaxWidth] wide on a tablet (≥ [soeTabletBreakpoint]).
Future<T?> showSoeAdaptivePanel<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (MediaQuery.sizeOf(context).width >= soeTabletBreakpoint) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppPalette.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        insetPadding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: soeReadableMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: builder(dialogContext),
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppPalette.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.band)),
    ),
    builder: (sheetContext) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: builder(sheetContext),
    ),
  );
}

/// Keeps [child] at most [soeReadableMaxWidth] wide, centred: fields and cards do not stretch
/// across a tablet.
class SoeReadableWidth extends StatelessWidget {
  const SoeReadableWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: soeReadableMaxWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      );
}

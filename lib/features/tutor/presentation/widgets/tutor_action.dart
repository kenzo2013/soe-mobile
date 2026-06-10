import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';

/// Message utilisateur pour une `Failure` (CDC §7.4).
String tutorFailureMessage(Translations tr, Failure f) => switch (f) {
      NetworkFailure() => tr.tutor.errors.network,
      TimeoutFailure() => tr.tutor.errors.timeout,
      UnauthorizedFailure() => tr.tutor.errors.unauthorized,
      ForbiddenFailure() => tr.tutor.errors.forbidden,
      NotFoundFailure() => tr.tutor.errors.notFound,
      ConflictFailure(:final message) => message ?? tr.tutor.errors.conflict,
      ValidationFailure(:final message) =>
        message ?? tr.tutor.errors.validation,
      ServerFailure(:final message) => message ?? tr.tutor.errors.server,
      _ => tr.tutor.errors.unknown,
    };

/// Exécute une mutation tuteur avec retour utilisateur standardisé :
/// toast succès/erreur, pop optionnel, callback succès (ex. refresh liste).
///
/// Pas de `BuildContext` dans le VM : la View pilote le feedback ici.
Future<bool> runTutorAction(
  BuildContext context,
  WidgetRef ref, {
  required String actionKey,
  required Future<Result<void, Failure>> Function() op,
  String? successMessage,
  bool popOnSuccess = true,
  VoidCallback? onSuccess,
}) async {
  final tr = Translations.of(context);
  final vm = ref.read(tutorActionViewModelProvider(actionKey).notifier);
  final ok = await vm.run(op);
  if (!context.mounted) return ok;
  if (ok) {
    SoeToast.show(
      context,
      message: successMessage ?? tr.common.saved,
      tone: SoeToastTone.success,
    );
    onSuccess?.call();
    if (popOnSuccess && context.canPop()) context.pop();
  } else {
    final state = ref.read(tutorActionViewModelProvider(actionKey));
    final message = state is TutorActionError
        ? tutorFailureMessage(tr, state.failure)
        : tr.tutor.errors.unknown;
    SoeToast.show(context, message: message, tone: SoeToastTone.danger);
  }
  return ok;
}

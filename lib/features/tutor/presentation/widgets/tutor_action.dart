import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../providers.dart';
import '../viewmodels/tutor_async_state.dart';

/// Message utilisateur pour une `Failure` (CDC §7.4).
String tutorFailureMessage(Failure f) => switch (f) {
      NetworkFailure() => 'Pas de connexion réseau.',
      TimeoutFailure() => 'Le serveur met trop de temps à répondre.',
      UnauthorizedFailure() => 'Session expirée, veuillez vous reconnecter.',
      ForbiddenFailure() => 'Accès non autorisé.',
      NotFoundFailure() => 'Ressource introuvable.',
      ConflictFailure(:final message) =>
        message ?? 'Conflit : action déjà effectuée.',
      ValidationFailure(:final message) =>
        message ?? 'Veuillez vérifier les informations saisies.',
      ServerFailure(:final message) => message ?? 'Erreur serveur.',
      _ => 'Une erreur est survenue. Réessayez.',
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
  String successMessage = 'Enregistré',
  bool popOnSuccess = true,
  VoidCallback? onSuccess,
}) async {
  final vm = ref.read(tutorActionViewModelProvider(actionKey).notifier);
  final ok = await vm.run(op);
  if (!context.mounted) return ok;
  if (ok) {
    SoeToast.show(context, message: successMessage, tone: SoeToastTone.success);
    onSuccess?.call();
    if (popOnSuccess && context.canPop()) context.pop();
  } else {
    final state = ref.read(tutorActionViewModelProvider(actionKey));
    final message = state is TutorActionError
        ? tutorFailureMessage(state.failure)
        : 'Une erreur est survenue.';
    SoeToast.show(context, message: message, tone: SoeToastTone.danger);
  }
  return ok;
}

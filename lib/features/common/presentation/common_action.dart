import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/widgets/soe_toast.dart';
import '../../../i18n/translations.g.dart';

/// État d'une mutation des écrans communs.
sealed class CommonActionState {
  const CommonActionState();
}

class CommonActionIdle extends CommonActionState {
  const CommonActionIdle();
}

class CommonActionSubmitting extends CommonActionState {
  const CommonActionSubmitting();
}

class CommonActionSuccess extends CommonActionState {
  const CommonActionSuccess();
}

class CommonActionError extends CommonActionState {
  const CommonActionError(this.failure);
  final Failure failure;
}

/// VM générique de mutation (sans `BuildContext`). Gardes `mounted` pour les
/// providers `autoDispose` recyclés pendant l'`await`.
class CommonActionViewModel extends StateNotifier<CommonActionState> {
  CommonActionViewModel() : super(const CommonActionIdle());

  bool get isSubmitting => state is CommonActionSubmitting;

  Future<bool> run(Future<Result<void, Failure>> Function() op) async {
    if (state is CommonActionSubmitting) return false;
    state = const CommonActionSubmitting();
    final r = await op();
    return switch (r) {
      Ok() => () {
          if (mounted) state = const CommonActionSuccess();
          return true;
        }(),
      Err(:final failure) => () {
          if (mounted) state = CommonActionError(failure);
          return false;
        }(),
    };
  }
}

final commonActionViewModelProvider = StateNotifierProvider.autoDispose
    .family<CommonActionViewModel, CommonActionState, String>(
  (ref, _) => CommonActionViewModel(),
);

/// Message utilisateur pour une `Failure` (CDC §7.4).
String commonFailureMessage(Translations tr, Failure f) => switch (f) {
      NetworkFailure() => tr.errors.network,
      TimeoutFailure() => tr.errors.timeout,
      UnauthorizedFailure() => tr.errors.unauthorized,
      ForbiddenFailure() => tr.errors.forbidden,
      NotFoundFailure() => tr.errors.notFound,
      ConflictFailure(:final message) => message ?? tr.errors.conflict,
      ValidationFailure(:final message) => message ?? tr.errors.validation,
      ServerFailure(:final message) => message ?? tr.errors.server,
      _ => tr.errors.unknown,
    };

/// Exécute une mutation commune avec feedback standardisé (toast + pop + reload).
Future<bool> runCommonAction(
  BuildContext context,
  WidgetRef ref, {
  required String actionKey,
  required Future<Result<void, Failure>> Function() op,
  String? successMessage,
  bool popOnSuccess = true,
  VoidCallback? onSuccess,
}) async {
  final vm = ref.read(commonActionViewModelProvider(actionKey).notifier);
  final ok = await vm.run(op);
  if (!context.mounted) return ok;
  final tr = Translations.of(context);
  if (ok) {
    SoeToast.show(
      context,
      message: successMessage ?? tr.common.saved,
      tone: SoeToastTone.success,
    );
    onSuccess?.call();
    if (popOnSuccess && context.canPop()) context.pop();
  } else {
    final state = ref.read(commonActionViewModelProvider(actionKey));
    final message = state is CommonActionError
        ? commonFailureMessage(tr, state.failure)
        : tr.errors.unknown;
    SoeToast.show(context, message: message, tone: SoeToastTone.danger);
  }
  return ok;
}

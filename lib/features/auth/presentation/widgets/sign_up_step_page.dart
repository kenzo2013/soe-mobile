import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/soe_button.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../controllers/auth_controllers.dart';
import 'auth_feedback.dart';
import 'auth_scaffold.dart';

/// One sign-up step (AUT-03 to AUT-05): the API validates it, then [next] opens.
/// [missing] lists the empty required fields (« Il manque : prénom, nom. »).
class SignUpStepPage extends ConsumerWidget {
  const SignUpStepPage({
    super.key,
    required this.step,
    required this.number,
    required this.next,
    required this.children,
    required this.missing,
    this.submitLabel,
  });

  final SignUpStep step;
  final int number;
  final String next;
  final List<Widget> children;
  final List<String> missing;
  final String? submitLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).auth;
    final state = ref.watch(signUpControllerProvider);

    Future<void> submit() async {
      if (await ref.read(signUpControllerProvider.notifier).validate(step) &&
          context.mounted) {
        unawaited(context.push(next));
      }
    }

    return AuthScaffold(
      step: number,
      bottom: AuthSubmit(
        button: SoeButton(
          label: submitLabel ?? tr.kContinue,
          onPressed: missing.isEmpty ? submit : null,
          loading: state.busy,
          fullWidth: true,
        ),
        hint: missing.isEmpty ? null : tr.missing(fields: missing.join(', ')),
      ),
      children: [AuthErrorText(failure: state.failure), ...children],
    );
  }
}

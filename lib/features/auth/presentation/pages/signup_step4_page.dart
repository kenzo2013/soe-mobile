import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/repositories/auth_repository.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/register_flow_state.dart';
import '../viewmodels/register_flow_viewmodel.dart';
import '../viewmodels/register_viewmodel.dart';
import '../widgets/signup_header.dart';

class SignupStep4Page extends ConsumerStatefulWidget {
  const SignupStep4Page({super.key});

  @override
  ConsumerState<SignupStep4Page> createState() => _SignupStep4PageState();
}

class _SignupStep4PageState extends ConsumerState<SignupStep4Page> {
  late final TextEditingController _neighborhood;
  late final TextEditingController _city;
  bool _acceptCgu = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _neighborhood = TextEditingController(text: s.neighborhood)
      ..addListener(_syncAddress);
    _city = TextEditingController(text: s.city)..addListener(_syncAddress);
    _acceptCgu = s.acceptCgu;
  }

  void _syncAddress() {
    final flow = ref.read(registerFlowViewModelProvider);
    ref.read(registerFlowViewModelProvider.notifier).setAddress(
          neighborhood: _neighborhood.text,
          city: _city.text,
          country: flow.country,
          countryCode: flow.countryCode,
        );
  }

  @override
  void dispose() {
    _neighborhood
      ..removeListener(_syncAddress)
      ..dispose();
    _city
      ..removeListener(_syncAddress)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final state = ref.watch(registerViewModelProvider);
    final flow = ref.watch(registerFlowViewModelProvider);

    ref.listen<AuthState>(registerViewModelProvider, (prev, next) {
      next.whenOrNull(
        registered: (_) => context.go(RouteNames.emailSent),
        error: (f) => SoeToast.show(
          context,
          message: _label(f, tr),
          tone: SoeToastTone.danger,
        ),
      );
    });

    final isLoading =
        state.maybeWhen(loading: () => true, orElse: () => false);

    return Scaffold(
      backgroundColor: AppPalette.white,
      appBar: const SignupHeader(step: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(tr.signup.step4.heading, style: AppTypography.h2),
                const SizedBox(height: 6),
                Text(
                  tr.signup.step4.subtitle,
                  style:
                      AppTypography.bodySm.copyWith(color: AppPalette.n700),
                ),
                const SizedBox(height: 18),
                SoeTextField(
                  controller: _neighborhood,
                  label: tr.signup.step4.neighborhood,
                  leadingIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                SoeTextField(
                  controller: _city,
                  label: tr.signup.step4.city,
                  leadingIcon: Icons.location_city_outlined,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? tr.errors.required : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _acceptCgu,
                  onChanged: (v) {
                    setState(() => _acceptCgu = v ?? false);
                    ref
                        .read(registerFlowViewModelProvider.notifier)
                        .setAcceptCgu(value: _acceptCgu);
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppPalette.teal,
                  title: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySm
                          .copyWith(color: AppPalette.ink),
                      children: [
                        TextSpan(text: tr.signup.step4.cguPrefix),
                        TextSpan(
                          text: tr.signup.step4.cguTerms,
                          style: const TextStyle(
                            color: AppPalette.teal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: tr.signup.step4.cguAnd),
                        TextSpan(
                          text: tr.signup.step4.cguPrivacy,
                          style: const TextStyle(
                            color: AppPalette.teal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: tr.signup.step4.cguSuffix),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SoeButton(
                  label: tr.signup.step4.submit,
                  size: SoeButtonSize.lg,
                  fullWidth: true,
                  loading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () => _onSubmit(flow, tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(RegisterFlowState state, Translations tr) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptCgu) {
      SoeToast.show(
        context,
        message: tr.errors.cguRequired,
        tone: SoeToastTone.warning,
      );
      return;
    }
    final flow = ref.read(registerFlowViewModelProvider);
    ref.read(registerFlowViewModelProvider.notifier).setAddress(
          neighborhood: _neighborhood.text.trim(),
          city: _city.text.trim(),
          country: flow.country,
          countryCode: flow.countryCode,
        );
    ref.read(registerFlowViewModelProvider.notifier).setAcceptCgu(value: true);

    final fresh = ref.read(registerFlowViewModelProvider);

    // Préflight : on valide chaque étape AVANT d'appeler le repo. Si une étape
    // précédente a un champ invalide (ex. email mal formé), on ramène l'utilisateur
    // sur l'écran fautif avec un message clair, plutôt qu'un générique
    // "champs invalides" sur l'étape 4.
    final preflight = _findInvalidStep(fresh);
    if (preflight != null) {
      SoeToast.show(
        context,
        message: tr.errors.stepInvalid(
          step: preflight.step,
          field: preflight.fieldLabel(tr),
        ),
        tone: SoeToastTone.warning,
      );
      context.go(preflight.route);
      return;
    }

    ref.read(registerViewModelProvider.notifier).submit(
          RegisterParams(
            email: fresh.email,
            password: fresh.password,
            passwordConfirmation: fresh.passwordConfirmation,
            firstName: fresh.firstName,
            lastName: fresh.lastName,
            role: fresh.role,
            acceptCgu: true,
            civility: fresh.civility,
            phone: fresh.phone.isEmpty ? null : fresh.phone,
            lang: fresh.lang,
            neighborhood: _neighborhood.text.trim().isEmpty
                ? null
                : _neighborhood.text.trim(),
            city: _city.text.trim(),
            country: fresh.country,
            countryCode: fresh.countryCode,
          ),
        );
  }

  _StepIssue? _findInvalidStep(RegisterFlowState state) {
    // Étape 1 — identité
    if (state.firstName.trim().isEmpty) {
      return const _StepIssue(1, RouteNames.registerStep1, _Field.firstName);
    }
    if (state.lastName.trim().isEmpty) {
      return const _StepIssue(1, RouteNames.registerStep1, _Field.lastName);
    }
    // Étape 2 — contact
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(state.email)) {
      return const _StepIssue(2, RouteNames.registerStep2, _Field.email);
    }
    // Étape 3 — mot de passe
    if (state.password.length < 6) {
      return const _StepIssue(3, RouteNames.registerStep3, _Field.password);
    }
    if (state.password != state.passwordConfirmation) {
      return const _StepIssue(3, RouteNames.registerStep3, _Field.passwordConf);
    }
    return null;
  }

  String _label(Failure f, Translations tr) => switch (f) {
        ConflictFailure(:final message) =>
          message ?? tr.errors.validation,
        ValidationFailure(:final message) =>
          message ?? tr.errors.validation,
        NetworkFailure() => tr.errors.network,
        _ => tr.errors.unknown,
      };
}

enum _Field { firstName, lastName, email, password, passwordConf }

extension _FieldX on _Field {
  String fieldLabel(Translations tr) => switch (this) {
        _Field.firstName => tr.errors.fieldFirstName,
        _Field.lastName => tr.errors.fieldLastName,
        _Field.email => tr.errors.fieldEmail,
        _Field.password => tr.errors.fieldPassword,
        _Field.passwordConf => tr.errors.fieldPasswordConfirmation,
      };
}

class _StepIssue {
  const _StepIssue(this.step, this.route, this._field);
  final int step;
  final String route;
  final _Field _field;

  String fieldLabel(Translations tr) => _field.fieldLabel(tr);
}

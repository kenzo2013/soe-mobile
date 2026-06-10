import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/countries.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_checkbox.dart';
import '../../../../core/widgets/soe_country_field.dart';
import '../../../../core/widgets/soe_field_label.dart';
import '../../../../core/widgets/soe_places_autocomplete_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../core/services/places_service.dart';
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
  late final TextEditingController _search;
  late final TextEditingController _neighborhood;
  late final TextEditingController _city;
  bool _acceptCgu = false;
  late Country _country;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final s = ref.read(registerFlowViewModelProvider);
    _search = TextEditingController(text: s.address);
    _neighborhood = TextEditingController(text: s.neighborhood)
      ..addListener(_syncAddress);
    _city = TextEditingController(text: s.city)..addListener(_syncAddress);
    _country = Countries.byCode(s.countryCode);
    _acceptCgu = s.acceptCgu;
  }

  void _syncAddress() {
    ref.read(registerFlowViewModelProvider.notifier).setAddress(
          address: _search.text.trim().isEmpty ? null : _search.text.trim(),
          neighborhood: _neighborhood.text,
          city: _city.text,
          country: _country.name,
          countryCode: _country.code,
        );
  }

  void _onPlaceSelected(SoePlaceResult place) {
    setState(() {
      _search.text = place.formattedAddress;
      if (place.city.isNotEmpty) _city.text = place.city;
      if (place.neighborhood?.isNotEmpty ?? false) {
        _neighborhood.text = place.neighborhood!;
      }
      if (place.countryCode.isNotEmpty) {
        _country = Countries.byCode(place.countryCode);
      }
    });
    ref.read(registerFlowViewModelProvider.notifier).setAddressFromPlace(
          address: place.formattedAddress,
          city: place.city.isEmpty ? _city.text : place.city,
          country: place.country.isEmpty ? _country.name : place.country,
          countryCode:
              place.countryCode.isEmpty ? _country.code : place.countryCode,
          neighborhood: place.neighborhood,
        );
  }

  @override
  void dispose() {
    _search.dispose();
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
                SoeFieldLabel(tr.signup.step4.search),
                SoePlacesAutocompleteField(
                  controller: _search,
                  client: ref.watch(googlePlacesClientProvider),
                  hint: tr.signup.step4.searchHint,
                  onPlaceSelected: _onPlaceSelected,
                ),
                const SizedBox(height: 12),
                SoeFieldLabel(tr.signup.step4.neighborhood),
                SoeTextField(
                  controller: _neighborhood,
                  leadingIcon: Icons.public,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SoeFieldLabel(tr.signup.step4.city),
                          SoeTextField(
                            controller: _city,
                            hint: tr.signup.step4.cityHint,
                            textInputAction: TextInputAction.done,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? tr.errors.required
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SoeFieldLabel(tr.signup.step4.country),
                          SoeCountryField(
                            country: _country,
                            pickerTitle: tr.countryPicker.addressTitle,
                            onChanged: (c) {
                              setState(() => _country = c);
                              _syncAddress();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SoeCheckbox(
                  value: _acceptCgu,
                  onChanged: (v) {
                    setState(() => _acceptCgu = v);
                    ref
                        .read(registerFlowViewModelProvider.notifier)
                        .setAcceptCgu(value: v);
                  },
                  label: RichText(
                    text: TextSpan(
                      style: AppTypography.caption
                          .copyWith(color: AppPalette.ink, height: 1.5),
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
    ref.read(registerFlowViewModelProvider.notifier).setAddress(
          address: _search.text.trim().isEmpty ? null : _search.text.trim(),
          neighborhood: _neighborhood.text.trim(),
          city: _city.text.trim(),
          country: _country.name,
          countryCode: _country.code,
        );
    ref.read(registerFlowViewModelProvider.notifier).setAcceptCgu(value: true);

    final fresh = ref.read(registerFlowViewModelProvider);

    // Préflight : on valide chaque étape AVANT d'appeler le repo. Si une étape
    // précédente a un champ invalide, on ramène l'utilisateur sur l'écran fautif
    // avec un message clair.
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
            address: _search.text.trim().isEmpty ? null : _search.text.trim(),
            neighborhood: _neighborhood.text.trim().isEmpty
                ? null
                : _neighborhood.text.trim(),
            city: _city.text.trim(),
            country: _country.name,
            countryCode: _country.code,
          ),
        );
  }

  _StepIssue? _findInvalidStep(RegisterFlowState state) {
    if (state.firstName.trim().isEmpty) {
      return const _StepIssue(1, RouteNames.registerStep1, _Field.firstName);
    }
    if (state.lastName.trim().isEmpty) {
      return const _StepIssue(1, RouteNames.registerStep1, _Field.lastName);
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(state.email)) {
      return const _StepIssue(2, RouteNames.registerStep2, _Field.email);
    }
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

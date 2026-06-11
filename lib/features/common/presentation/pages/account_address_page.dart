import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_card.dart';
import '../../../../core/widgets/soe_places_autocomplete_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../i18n/translations.g.dart';
import '../../domain/entities/account_address.dart';
import '../common_action.dart';
import '../providers.dart';
import '../widgets/common_top_bar.dart';

/// 4 · Mon adresse (design `CommonAddress`).
class AccountAddressPage extends ConsumerWidget {
  const AccountAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context);
    final async = ref.watch(accountAddressProvider);
    return Scaffold(
      backgroundColor: AppPalette.n100,
      appBar: CommonTopBar(
        title: tr.account.address.title,
        subtitle: tr.account.address.subtitle,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          failure: e is Failure ? e : const UnknownFailure(),
          onRetry: () => ref.invalidate(accountAddressProvider),
        ),
        data: (address) => _AddressForm(address: address),
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({required this.address});
  final AccountAddress address;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  late final TextEditingController _address;
  late final TextEditingController _complement;
  late final TextEditingController _neighborhood;
  late final TextEditingController _city;
  late final TextEditingController _region;
  late final TextEditingController _country;
  late final TextEditingController _landmark;
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _address = TextEditingController(text: a.address ?? '');
    _complement = TextEditingController(text: a.complement ?? '');
    _neighborhood = TextEditingController(text: a.neighborhood ?? '');
    _city = TextEditingController(text: a.city ?? '');
    _region = TextEditingController(text: a.region ?? '');
    _country = TextEditingController(text: a.country ?? '');
    _landmark = TextEditingController(text: a.landmark ?? '');
    _countryCode = a.countryCode;
  }

  @override
  void dispose() {
    _address.dispose();
    _complement.dispose();
    _neighborhood.dispose();
    _city.dispose();
    _region.dispose();
    _country.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _onPlaceSelected(SoePlaceResult place) {
    setState(() {
      _address.text = place.formattedAddress;
      if (place.city.isNotEmpty) _city.text = place.city;
      if (place.neighborhood?.isNotEmpty ?? false) {
        _neighborhood.text = place.neighborhood!;
      }
      if (place.country.isNotEmpty) _country.text = place.country;
      if (place.countryCode.isNotEmpty) _countryCode = place.countryCode;
    });
  }

  Future<void> _save() async {
    final tr = Translations.of(context);
    final updated = widget.address.copyWith(
      address: _address.text.trim(),
      complement: _complement.text.trim(),
      neighborhood: _neighborhood.text.trim(),
      city: _city.text.trim(),
      region: _region.text.trim(),
      country: _country.text.trim(),
      countryCode: _countryCode,
      landmark: _landmark.text.trim(),
    );
    await runCommonAction(
      context,
      ref,
      actionKey: 'address',
      successMessage: tr.account.address.saved,
      popOnSuccess: false,
      op: () async {
        final r =
            await ref.read(commonRepositoryProvider).updateAddress(updated);
        return switch (r) {
          Ok() => const Ok<void, Failure>(null),
          Err(:final failure) => Err<void, Failure>(failure),
        };
      },
      onSuccess: () => ref.invalidate(accountAddressProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final submitting = ref.watch(commonActionViewModelProvider('address'))
        is CommonActionSubmitting;
    FlutterGooglePlacesSdk? places;
    try {
      places = ref.watch(googlePlacesClientProvider);
    } catch (_) {
      places = null; // clé absente → saisie manuelle
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _MapPlaceholder(),
        const SizedBox(height: 14),
        SoeCard(
          child: Column(
            children: [
              if (places != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      tr.account.address.googlePlacesLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.n700,
                      ),
                    ),
                  ),
                ),
                SoePlacesAutocompleteField(
                  controller: _address,
                  client: places,
                  hint: tr.account.address.searchHint,
                  onPlaceSelected: _onPlaceSelected,
                ),
              ] else
                SoeTextField(
                  controller: _address,
                  label: tr.account.address.addressLabel,
                  leadingIcon: Icons.search,
                ),
              const SizedBox(height: 12),
              SoeTextField(
                controller: _complement,
                label: tr.account.address.complementLabel,
                leadingIcon: Icons.public,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SoeTextField(
                      controller: _neighborhood,
                      label: tr.account.address.neighborhoodLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SoeTextField(
                      controller: _city,
                      label: tr.account.address.cityLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SoeTextField(
                      controller: _region,
                      label: tr.account.address.regionLabel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SoeTextField(
                      controller: _country,
                      label: tr.account.address.countryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoeTextField(
                controller: _landmark,
                label: tr.account.address.landmarkLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SoeButton(
          label: tr.account.address.save,
          fullWidth: true,
          loading: submitting,
          onPressed: submitting ? null : _save,
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.n300),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.n300, AppPalette.n100],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.location_on, size: 40, color: AppPalette.danger),
    );
  }
}

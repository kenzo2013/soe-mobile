import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/places_service.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_button.dart';
import '../../../../core/widgets/soe_places_autocomplete_field.dart';
import '../../../../core/widgets/soe_text_field.dart';
import '../../../../core/widgets/soe_toast.dart';
import '../../../../i18n/translations.g.dart';
import '../../../tutor_space/data/tutor_location.dart';
import '../../data/account_models.dart';
import '../providers.dart';
import '../widgets/account_ui.dart';
import '../../../../core/widgets/soe_city_field.dart';

/// Reads the phone's position for « Utiliser ma position » (replaced in tests).
final addressLocatorProvider =
    Provider<Future<({double latitude, double longitude})?> Function()>(
        (ref) => () async => (await tutorLocate()).position);

/// COM-04 — the address: search, neighbourhood, city, landmark and the exact position. Parent:
/// where the lessons take place, also the tutor's check-in point (within the radius set by
/// SOE). Tutor: where they live, to be offered families nearby.
class AccountAddressPage extends ConsumerWidget {
  const AccountAddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = Translations.of(context).accountSpace.address;
    final address = ref.watch(accountAddressProvider);
    final loaded = address.valueOrNull;
    if (loaded != null) return _AddressForm(address: loaded);
    return AccountScaffold(title: tr.title, crumb: tr.crumb, children: [
      AccountAsync(
        value: address,
        onRetry: () => ref.invalidate(accountAddressProvider),
        builder: (_) => const SizedBox.shrink(),
      ),
    ]);
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({required this.address});

  final AccountAddress address;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _search = TextEditingController();
  late final _neighborhood =
      TextEditingController(text: widget.address.neighborhood ?? '');
  late final _landmark =
      TextEditingController(text: widget.address.landmark ?? '');
  late String? _city = widget.address.city;
  late double? _latitude = widget.address.latitude;
  late double? _longitude = widget.address.longitude;
  bool _locating = false;
  bool _saving = false;
  Failure? _error;

  @override
  void dispose() {
    _search.dispose();
    _neighborhood.dispose();
    _landmark.dispose();
    super.dispose();
  }

  void _onPlace(SoePlaceResult place) => setState(() {
        if ((place.neighborhood ?? '').isNotEmpty) {
          _neighborhood.text = place.neighborhood!;
        }
        if (place.city.isNotEmpty) _city = place.city;
      });

  Future<void> _locate() async {
    final tr = Translations.of(context).accountSpace.address;
    setState(() => _locating = true);
    final position = await ref.read(addressLocatorProvider)();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
      }
    });
    if (position == null) {
      SoeToast.show(context,
          message: tr.unavailable, tone: SoeToastTone.warning);
    }
  }

  Future<void> _save() async {
    final tr = Translations.of(context).accountSpace.address;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await ref.read(accountApiProvider).updateAddress(
            AccountAddress(
              neighborhood: _neighborhood.text.trim(),
              city: _city,
              landmark: _landmark.text.trim(),
              latitude: _latitude,
              longitude: _longitude,
            ),
          );
      ref.invalidate(accountAddressProvider);
      if (!mounted) return;
      SoeToast.show(context, message: tr.saved);
      if (context.canPop()) context.pop(saved);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _error = failure);
      SoeToast.show(context,
          message: accountFailureMessage(context, failure),
          tone: SoeToastTone.danger);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context).accountSpace.address;
    final tutor = ref.watch(currentRoleProvider) == 'tutor';
    FlutterGooglePlacesSdk? places;
    try {
      places = ref.watch(googlePlacesClientProvider);
    } on StateError {
      places = null; // No key in this build: the fields are typed by hand.
    }
    final place = [_neighborhood.text.trim(), _city ?? '']
        .where((part) => part.isNotEmpty)
        .join(', ');
    return AccountScaffold(
      title: tr.title,
      crumb: tr.crumb,
      bottom: SoeButton(
        label: tr.save,
        fullWidth: true,
        loading: _saving,
        onPressed: _saving ? null : () => unawaited(_save()),
      ),
      children: [
        AccountPageTitle(tutor ? tr.headingTutor : tr.headingParent,
            subtitle: tutor ? tr.introTutor : tr.introParent),
        AccountCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (places != null) ...[
              AccountFieldLabel(tr.search),
              SoePlacesAutocompleteField(
                controller: _search,
                client: places,
                hint: tr.neighborhoodHint,
                onPlaceSelected: _onPlace,
              ),
            ],
            AccountFieldLabel(tr.neighborhood),
            SoeTextField(
              controller: _neighborhood,
              hint: tr.neighborhoodHint,
              onChanged: (_) => setState(() {}),
              errorText: fieldError(_error, 'neighborhood'),
            ),
            AccountFieldLabel(tr.city),
            SoeCityField(
              value: _city,
              semanticLabel: tr.city,
              errorText: fieldError(_error, 'city'),
              onChanged: (city) => setState(() => _city = city),
            ),
            AccountFieldLabel(tr.landmark),
            SoeTextField(
              controller: _landmark,
              hint: tr.landmarkHint,
              errorText: fieldError(_error, 'landmark'),
            ),
          ]),
        ),
        AccountCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AccountCardTitle(tr.position),
            _MiniMap(
              place: place,
              latitude: _latitude,
              longitude: _longitude,
              semanticLabel: tr.mapLabel,
            ),
            const SizedBox(height: 12),
            SoeButton(
              label: _locating ? tr.locating : tr.useMyPosition,
              icon: Icons.my_location,
              variant: SoeButtonVariant.outline,
              size: SoeButtonSize.md,
              loading: _locating,
              onPressed: _locating ? null : () => unawaited(_locate()),
            ),
            const SizedBox(height: 12),
            Text(
              tutor
                  ? tr.mapHelpTutor
                  : tr.mapHelpParent(
                      meters: widget.address.checkInRadiusMeters),
              style: AppTypography.caption.copyWith(color: AppPalette.text2),
            ),
          ]),
        ),
      ],
    );
  }
}

/// A plan of the place (no map service in the app yet): streets, the pin when a position is
/// set, the place and the coordinates.
class _MiniMap extends StatelessWidget {
  const _MiniMap({
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.semanticLabel,
  });

  final String place;
  final double? latitude;
  final double? longitude;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final pinned = latitude != null && longitude != null;
    return Semantics(
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 200,
          child: Stack(children: [
            const Positioned.fill(
                child: CustomPaint(painter: _StreetsPainter())),
            if (pinned)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.location_on_outlined,
                      key: Key('address-pin'),
                      size: 36,
                      color: AppPalette.danger),
                ),
              ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                if (place.isNotEmpty) _Chip(place),
                if (pinned)
                  _Chip(
                      '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: AppPalette.white, borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: AppTypography.caption.copyWith(color: AppPalette.text2)),
      );
}

class _StreetsPainter extends CustomPainter {
  const _StreetsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEFF4F6));
    final street = Paint()
      ..color = AppPalette.white
      ..strokeWidth = 8;
    canvas
      ..drawLine(Offset(size.width * .38, 0),
          Offset(size.width * .38, size.height), street)
      ..drawLine(Offset(0, size.height * .5),
          Offset(size.width, size.height * .5), street);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

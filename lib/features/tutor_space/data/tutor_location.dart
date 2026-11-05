import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'tutor_api.dart';

/// The current position for the check-in, or null when the location is off, refused, or not
/// found in time: the screen then offers the parent's 4-digit code.
Future<TutorPosition?> tutorCurrentPosition() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  } on TimeoutException {
    return null;
  } on Exception {
    return null;
  }
}

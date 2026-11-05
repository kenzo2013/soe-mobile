import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'tutor_api.dart';

/// Why no usable position was read for the check-in.
enum TutorLocationIssue { off, denied, deniedForever, approximate, notFound }

/// The current position for the check-in, or the reason it is missing: location off, refused,
/// approximate only (Android 12+, too imprecise for the check-in radius) or not found in time. The
/// screen then explains it, offers the settings when they can fix it, and the parent's code.
Future<({TutorPosition? position, TutorLocationIssue? issue})>
    tutorLocate() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return (position: null, issue: TutorLocationIssue.off);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return (position: null, issue: TutorLocationIssue.deniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return (position: null, issue: TutorLocationIssue.denied);
    }
    if (await Geolocator.getLocationAccuracy() ==
        LocationAccuracyStatus.reduced) {
      return (position: null, issue: TutorLocationIssue.approximate);
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return (
      position: (latitude: position.latitude, longitude: position.longitude),
      issue: null,
    );
  } on TimeoutException {
    return (position: null, issue: TutorLocationIssue.notFound);
  } on Exception {
    return (position: null, issue: TutorLocationIssue.notFound);
  }
}

/// The position only (check-out: sent when available).
Future<TutorPosition?> tutorCurrentPosition() async =>
    (await tutorLocate()).position;

/// The settings that can fix an issue: the location service, else the app's permissions.
Future<bool> tutorOpenLocationSettings(TutorLocationIssue issue) =>
    issue == TutorLocationIssue.off
        ? Geolocator.openLocationSettings()
        : Geolocator.openAppSettings();

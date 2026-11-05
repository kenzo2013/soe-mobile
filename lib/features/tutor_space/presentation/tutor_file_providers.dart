import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/core_providers.dart';
import '../data/tutor_file_api.dart';
import '../data/tutor_file_models.dart';
import 'providers.dart';

/// Reads of the recruitment journey (REP-02 to REP-09, REP-23, REP-24). Each screen refreshes
/// them after an action ([refreshTutorFile]).
final tutorFileApiProvider =
    Provider<TutorFileApi>((ref) => TutorFileApi(ref.watch(dioV2Provider)));

final tutorFileProvider = FutureProvider.autoDispose<TutorFile>(
    (ref) => ref.watch(tutorFileApiProvider).file());

final tutorFileSectionProvider = FutureProvider.autoDispose
    .family<TutorFileSection, String>(
        (ref, section) => ref.watch(tutorFileApiProvider).section(section));

final tutorInterviewProvider = FutureProvider.autoDispose<TutorInterview>(
    (ref) => ref.watch(tutorFileApiProvider).interview());

final tutorCharterProvider = FutureProvider.autoDispose<TutorCharter>(
    (ref) => ref.watch(tutorFileApiProvider).charter());

/// Takes a photo with the camera or picks one in the gallery (images only: the PDF of the web
/// form has no picker here). Overridden in the tests.
class TutorImagePicker {
  const TutorImagePicker();

  Future<TutorUpload?> pick({required bool camera}) async {
    final file = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (file == null) return null;
    return TutorUpload(bytes: await file.readAsBytes(), filename: file.name);
  }
}

final tutorImagePickerProvider =
    Provider<TutorImagePicker>((ref) => const TutorImagePicker());

/// Refreshes what a change of the file touches: the file, the section, the home.
void refreshTutorFile(WidgetRef ref, [String? section]) {
  ref
    ..invalidate(tutorFileProvider)
    ..invalidate(tutorHomeProvider);
  if (section != null) ref.invalidate(tutorFileSectionProvider(section));
}

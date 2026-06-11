import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_palette.dart';

/// Source choisie par l'utilisateur dans le bottom sheet.
enum AvatarSource { camera, gallery }

/// Service centralisé pour choisir + cropper une photo de profil.
///
/// Usage :
/// ```dart
/// final file = await AvatarPickerService.pick(context);
/// if (file != null) setState(() => _avatar = file);
/// ```
abstract final class AvatarPickerService {
  static final _picker = ImagePicker();
  static final _cropper = ImageCropper();

  /// Affiche le bottom sheet, lance le picker selon le choix, puis le
  /// cropper en carré 1:1. Renvoie le `File` final ou `null` si annulé.
  static Future<File?> pick(BuildContext context) async {
    final source = await _showSourceSheet(context);
    if (source == null) return null;

    final picked = await _picker.pickImage(
      source: source == AvatarSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return null;

    final cropped = await _cropper.cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer la photo',
          toolbarColor: AppPalette.teal,
          toolbarWidgetColor: Colors.white,
          backgroundColor: AppPalette.ink,
          activeControlsWidgetColor: AppPalette.yellow,
          statusBarLight: false,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Recadrer',
          aspectRatioLockEnabled: true,
          minimumAspectRatio: 1,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return cropped == null ? null : File(cropped.path);
  }

  static Future<AvatarSource?> _showSourceSheet(BuildContext context) {
    return showModalBottomSheet<AvatarSource>(
      context: context,
      backgroundColor: AppPalette.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _SourceSheet(),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppPalette.n300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Photo de profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choisissez la source de la photo',
              style: TextStyle(fontSize: 13, color: AppPalette.n700),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _SourceTile(
                    icon: Icons.photo_camera_outlined,
                    label: 'Caméra',
                    description: 'Prendre une photo',
                    onTap: () => Navigator.of(context).pop(AvatarSource.camera),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SourceTile(
                    icon: Icons.photo_library_outlined,
                    label: 'Galerie',
                    description: 'Depuis votre téléphone',
                    onTap: () =>
                        Navigator.of(context).pop(AvatarSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppPalette.n700,
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.n50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppPalette.n300, width: 1),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppPalette.infoBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: AppPalette.teal),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppPalette.n700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

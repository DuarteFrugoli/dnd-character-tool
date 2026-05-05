import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// A tappable circular avatar that shows the character photo (if set)
/// or the first letter of their name as fallback.
///
/// When tapped, shows a bottom sheet to pick a new photo or delete the
/// existing one. The cropped file path is returned via [onImageChanged].
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.radius = 24,
    this.onImageChanged,
  });

  final String name;
  final String? imagePath;
  final double radius;

  /// Called with the new file path after picking/cropping, or `null` when
  /// the photo is deleted. If null, the avatar is not interactive.
  final void Function(String? path)? onImageChanged;

  Future<void> _handleTap(BuildContext context) async {
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose photo'),
              onTap: () => Navigator.pop(ctx, _AvatarAction.pick),
            ),
            if (imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove photo'),
                onTap: () => Navigator.pop(ctx, _AvatarAction.delete),
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );

    if (action == null) return;

    if (action == _AvatarAction.delete) {
      onImageChanged?.call(null);
      return;
    }

    // Pick
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Crop to 1:1
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop photo',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Crop photo',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;
    onImageChanged?.call(cropped.path);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      backgroundImage:
          imagePath != null ? FileImage(File(imagePath!)) : null,
      child: imagePath == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: radius * 0.75,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    if (onImageChanged == null) return avatar;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 1.5),
              ),
              child: Icon(Icons.camera_alt, size: radius * 0.45, color: cs.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AvatarAction { pick, delete }

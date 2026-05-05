import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

/// Opens the photo picker / remove bottom sheet and calls [onImageChanged]
/// with the resulting path (or `null` for removal). Can be called from
/// anywhere — e.g. from a popup menu — without needing a [CharacterAvatar].
Future<void> showCharacterPhotoPicker(
  BuildContext context, {
  required String? currentImagePath,
  required void Function(String? path) onImageChanged,
}) async {
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
          if (currentImagePath != null)
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
    onImageChanged(null);
    return;
  }

  final picker = ImagePicker();
  final XFile? picked;
  try {
    picked = await picker.pickImage(source: ImageSource.gallery);
  } catch (_) {
    return;
  }
  if (picked == null) return;
  if (!context.mounted) return;

  final CroppedFile? cropped;
  try {
    cropped = await ImageCropper().cropImage(
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
        WebUiSettings(context: context, presentStyle: WebPresentStyle.dialog),
      ],
    );
  } catch (_) {
    return;
  }

  if (cropped == null) return;

  // On web, blob URLs are temporary — convert to a base64 data URL so the
  // image survives page refreshes and can be stored in the character JSON.
  if (kIsWeb) {
    final bytes = await cropped.readAsBytes();
    final encoded = base64Encode(bytes);
    onImageChanged('data:image/jpeg;base64,$encoded');
  } else {
    onImageChanged(cropped.path);
  }
}

/// Returns the appropriate [ImageProvider] for [path]:
/// - base64 data URL (web storage) → [MemoryImage]
/// - file path (mobile) → [FileImage]
ImageProvider _resolveImageProvider(String path) {
  if (path.startsWith('data:')) {
    final base64Data = path.split(',').last;
    return MemoryImage(base64Decode(base64Data));
  }
  return FileImage(File(path));
}

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      backgroundImage: imagePath != null ? _resolveImageProvider(imagePath!) : null,
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
      onTap: () => showCharacterPhotoPicker(
        context,
        currentImagePath: imagePath,
        onImageChanged: onImageChanged!,
      ),
      child: avatar,
    );
  }
}

enum _AvatarAction { pick, delete }

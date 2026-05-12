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

    final interactive = imagePath != null
        ? Hero(tag: 'character_avatar_$imagePath', child: avatar)
        : avatar;

    return GestureDetector(
      onTap: () {
        if (imagePath != null) {
          _showPhotoViewer(
            context,
            imagePath: imagePath!,
            onImageChanged: onImageChanged!,
          );
        } else {
          showCharacterPhotoPicker(
            context,
            currentImagePath: null,
            onImageChanged: onImageChanged!,
          );
        }
      },
      child: interactive,
    );
  }
}

// ── Full-screen photo viewer ─────────────────────────────────────────────────

Future<void> _showPhotoViewer(
  BuildContext context, {
  required String imagePath,
  required void Function(String? path) onImageChanged,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => _PhotoViewerPage(
        imagePath: imagePath,
        onImageChanged: onImageChanged,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _PhotoViewerPage extends StatelessWidget {
  const _PhotoViewerPage({
    required this.imagePath,
    required this.onImageChanged,
  });

  final String imagePath;
  final void Function(String? path) onImageChanged;

  @override
  Widget build(BuildContext context) {
    final image = _resolveImageProvider(imagePath);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Tap outside to close
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox.expand(),
          ),

          // Photo centered
          Center(
            child: Hero(
              tag: 'character_avatar_$imagePath',
              child: Image(
                image: image,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Top bar: close button
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black45,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              padding: EdgeInsets.fromLTRB(16, 24, 16, bottomPadding + 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ViewerAction(
                    icon: Icons.edit_outlined,
                    label: 'Alterar foto',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await showCharacterPhotoPicker(
                        context,
                        currentImagePath: imagePath,
                        onImageChanged: onImageChanged,
                      );
                    },
                  ),
                  _ViewerAction(
                    icon: Icons.delete_outline,
                    label: 'Remover foto',
                    onTap: () {
                      Navigator.of(context).pop();
                      onImageChanged(null);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerAction extends StatelessWidget {
  const _ViewerAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

enum _AvatarAction { pick, delete }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

/// Directly opens the image picker + cropper and calls [onChanged] with the
/// resulting path. No bottom sheet shown.
Future<void> _pickAndCrop(
  BuildContext context, {
  required void Function(String? path) onChanged,
}) async {

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
          toolbarTitle: AppLocalizations.of(context)?.avatarCropPhoto ?? 'Crop photo',
          lockAspectRatio: true,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: AppLocalizations.of(context)?.avatarCropPhoto ?? 'Crop photo',
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
    onChanged('data:image/jpeg;base64,$encoded');
  } else {
    onChanged(cropped.path);
  }
}

/// Opens a bottom sheet with pick / remove options and calls [onImageChanged].
/// Can be called from anywhere without a [CharacterAvatar].
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
            title: Text(AppLocalizations.of(ctx)?.avatarChoosePhoto ?? 'Choose photo'),
            onTap: () => Navigator.pop(ctx, _AvatarAction.pick),
          ),
          if (currentImagePath != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(AppLocalizations.of(ctx)?.avatarRemovePhoto ?? 'Remove photo'),
              onTap: () => Navigator.pop(ctx, _AvatarAction.delete),
            ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(AppLocalizations.of(ctx)?.dialogCancel ?? 'Cancel'),
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );

  if (action == null || !context.mounted) return;

  if (action == _AvatarAction.delete) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)?.avatarRemoveConfirmTitle ?? 'Remove photo?'),
        content: Text(AppLocalizations.of(ctx)?.avatarRemoveConfirmBody ?? 'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)?.dialogCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(ctx)?.avatarRemovePhoto ?? 'Remove',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) onImageChanged(null);
    return;
  }

  await _pickAndCrop(context, onChanged: onImageChanged);
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

enum _ViewerResult { pick, remove }

Future<void> _showPhotoViewer(
  BuildContext context, {
  required String imagePath,
  required void Function(String? path) onImageChanged,
}) async {
  final result = await Navigator.of(context).push<_ViewerResult>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => _PhotoViewerPage(imagePath: imagePath),
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );

  if (!context.mounted) return;

  if (result == _ViewerResult.remove) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)?.avatarRemoveConfirmTitle ?? 'Remove photo?'),
        content: Text(AppLocalizations.of(ctx)?.avatarRemoveConfirmBody ?? 'This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)?.dialogCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(ctx)?.avatarRemovePhoto ?? 'Remove',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) onImageChanged(null);
  } else if (result == _ViewerResult.pick) {
    await _pickAndCrop(context, onChanged: onImageChanged);
  }
}

class _PhotoViewerPage extends StatelessWidget {
  const _PhotoViewerPage({required this.imagePath});

  final String imagePath;

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

          // Photo filling the screen (contain keeps aspect ratio)
          Positioned.fill(
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
                    label: AppLocalizations.of(context)?.avatarChangePhoto ?? 'Change photo',
                    onTap: () => Navigator.of(context).pop(_ViewerResult.pick),
                  ),
                  _ViewerAction(
                    icon: Icons.delete_outline,
                    label: AppLocalizations.of(context)?.avatarRemovePhoto ?? 'Remove photo',
                    onTap: () => Navigator.of(context).pop(_ViewerResult.remove),
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

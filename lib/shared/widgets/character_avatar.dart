import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/platform/character_image.dart';
import '../../l10n/app_localizations.dart';

const _maxAvatarImageDimension = 1024;

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
      maxWidth: _maxAvatarImageDimension,
      maxHeight: _maxAvatarImageDimension,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle:
              AppLocalizations.of(context)?.avatarCropPhoto ?? 'Crop photo',
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

  // On web, blob URLs are temporary; pass a data URL to the repository so the
  // backend can store the image in IndexedDB.
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
            title: Text(
              AppLocalizations.of(ctx)?.avatarChoosePhoto ?? 'Choose photo',
            ),
            onTap: () => Navigator.pop(ctx, _AvatarAction.pick),
          ),
          if (currentImagePath != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(
                AppLocalizations.of(ctx)?.avatarRemovePhoto ?? 'Remove photo',
              ),
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
        title: Text(
          AppLocalizations.of(ctx)?.avatarRemoveConfirmTitle ?? 'Remove photo?',
        ),
        content: Text(
          AppLocalizations.of(ctx)?.avatarRemoveConfirmBody ??
              'This action cannot be undone.',
        ),
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
/// - base64 data URL (web storage) uses [MemoryImage]
/// - file path (native storage) uses the platform image provider
ImageProvider _resolveImageProvider(String path) {
  return resolveCharacterImageProvider(path);
}

/// A tappable circular avatar that shows the character photo (if set)
/// or the first letter of their name as fallback.
///
/// When tapped, shows a bottom sheet to pick a new photo or delete the
/// existing one. The cropped file path is returned via [onImageChanged].
class CharacterAvatar extends StatefulWidget {
  const CharacterAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.radius = 24,
    this.onImageChanged,
    this.heroTag,
  });

  final String name;
  final String? imagePath;
  final double radius;
  final Object? heroTag;

  /// Called with the new file path after picking/cropping, or `null` when
  /// the photo is deleted. If null, the avatar is not interactive.
  final void Function(String? path)? onImageChanged;

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar> {
  String? _precachedImagePath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheCurrentImage();
  }

  @override
  void didUpdateWidget(CharacterAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _precacheCurrentImage();
    }
  }

  void _precacheCurrentImage() {
    final path = widget.imagePath;
    if (path == null || path == _precachedImagePath) return;
    _precachedImagePath = path;
    final image = _resolveImageProvider(path);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.imagePath != path) return;
      precacheImage(image, context).catchError((_) {
        image.evict();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _AvatarCircle(
      name: widget.name,
      imagePath: widget.imagePath,
      radius: widget.radius,
    );

    if (widget.onImageChanged == null) return avatar;

    final resolvedHeroTag =
        widget.heroTag ??
        (widget.imagePath != null
            ? 'character_avatar_${widget.imagePath}'
            : null);
    final interactive = resolvedHeroTag != null
        ? Hero(
            tag: resolvedHeroTag,
            placeholderBuilder: (_, heroSize, _) => _AvatarCircle.fromHeroSize(
              name: widget.name,
              imagePath: widget.imagePath,
              heroSize: heroSize,
            ),
            flightShuttleBuilder: (_, _, _, _, _) => Material(
              type: MaterialType.transparency,
              child: _AvatarCircle(
                name: widget.name,
                imagePath: widget.imagePath,
                radius: widget.radius,
              ),
            ),
            child: avatar,
          )
        : avatar;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (widget.imagePath != null) {
            _showPhotoViewer(
              context,
              imagePath: widget.imagePath!,
              characterName: widget.name,
              onImageChanged: widget.onImageChanged!,
            );
          } else {
            showCharacterPhotoPicker(
              context,
              currentImagePath: null,
              onImageChanged: widget.onImageChanged!,
            );
          }
        },
        child: interactive,
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.name,
    required this.imagePath,
    required this.radius,
  });

  factory _AvatarCircle.fromHeroSize({
    required String name,
    required String? imagePath,
    required Size heroSize,
  }) {
    final shortestSide = math.min(heroSize.width, heroSize.height);
    return _AvatarCircle(
      name: name,
      imagePath: imagePath,
      radius: shortestSide / 2,
    );
  }

  final String name;
  final String? imagePath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diameter = radius * 2;
    final image = imagePath != null ? _resolveImageProvider(imagePath!) : null;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: radius * 0.75,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (image != null)
                Image(
                  key: ValueKey(imagePath),
                  image: image,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) {
                    image.evict();
                    return const SizedBox.shrink();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Full-screen photo viewer.

enum _ViewerResult { pick, remove }

Future<void> _showPhotoViewer(
  BuildContext context, {
  required String imagePath,
  required String characterName,
  required void Function(String? path) onImageChanged,
}) async {
  final result = await Navigator.of(context).push<_ViewerResult>(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) =>
          _PhotoViewerPage(imagePath: imagePath, characterName: characterName),
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
        title: Text(
          AppLocalizations.of(ctx)?.avatarRemoveConfirmTitle ?? 'Remove photo?',
        ),
        content: Text(
          AppLocalizations.of(ctx)?.avatarRemoveConfirmBody ??
              'This action cannot be undone.',
        ),
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

class _PhotoViewerPage extends StatefulWidget {
  const _PhotoViewerPage({
    required this.imagePath,
    required this.characterName,
  });

  final String imagePath;
  final String characterName;

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage>
    with SingleTickerProviderStateMixin {
  final _transformController = TransformationController();
  late final AnimationController _animController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;
  Size? _imageSize;
  // Centering transform computed once layout + image size are both known.
  Matrix4 _centeredTransform = Matrix4.identity();
  bool _transformReady = false;
  // Cached layout values read by the live clamp listener.
  double _screenW = 0;
  double _screenH = 0;
  double _fittedW = 0;
  double _fittedH = 0;
  bool _clamping = false;

  bool get _isZoomed => _transformController.value.getMaxScaleOnAxis() > 1.05;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_animation != null) {
            _transformController.value = _animation!.value;
          }
        });
    _transformController.addListener(() {
      _clampTransform();
      if (mounted) setState(() {});
    });

    // Load image dimensions to calculate exact boundary
    _resolveImageProvider(widget.imagePath)
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            if (mounted) {
              setState(() {
                _imageSize = Size(
                  info.image.width.toDouble(),
                  info.image.height.toDouble(),
                );
              });
            }
          }),
        );
  }

  @override
  void dispose() {
    _transformController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _onDoubleTap() {
    final Matrix4 end;
    if (_isZoomed) {
      end = _centeredTransform;
    } else {
      const s = 3.0;
      final cx = _centeredTransform.getTranslation().x;
      final cy = _centeredTransform.getTranslation().y;
      final px = _doubleTapDetails!.localPosition.dx;
      final py = _doubleTapDetails!.localPosition.dy;
      end = Matrix4.identity()
        ..translateByDouble(
          px * (1 - s) + s * cx,
          py * (1 - s) + s * cy,
          0.0,
          1.0,
        )
        ..scaleByDouble(s, s, 1.0, 1.0);
    }
    _animateTo(end);
  }

  void _animateTo(Matrix4 target) {
    _animation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);
  }

  /// WhatsApp-style boundary clamping, fired on every controller change.
  /// Rules applied independently per axis:
  ///   scaledDim > screenDim: pan clamped to [screenDim - scaledDim, 0]
  ///   scaledDim <= screenDim: centered (shows black bars on that axis)
  void _clampTransform() {
    if (_clamping || _fittedW == 0 || _screenW == 0) return;
    final m = _transformController.value;
    final s = m.getMaxScaleOnAxis();
    final tx = m.getTranslation().x;
    final ty = m.getTranslation().y;
    final scaledW = s * _fittedW;
    final scaledH = s * _fittedH;

    final double clampedTx = scaledW >= _screenW
        ? tx.clamp(_screenW - scaledW, 0.0)
        : (_screenW - scaledW) / 2;
    final double clampedTy = scaledH >= _screenH
        ? ty.clamp(_screenH - scaledH, 0.0)
        : (_screenH - scaledH) / 2;

    if ((clampedTx - tx).abs() > 0.5 || (clampedTy - ty).abs() > 0.5) {
      _clamping = true;
      _transformController.value = Matrix4.identity()
        ..translateByDouble(clampedTx, clampedTy, 0.0, 1.0)
        ..scaleByDouble(s, s, 1.0, 1.0);
      _clamping = false;
    }
  }

  Future<void> _saveToGallery() async {
    final path = widget.imagePath;
    final l10n = AppLocalizations.of(context);
    final safeName = widget.characterName.replaceAll(RegExp(r'[^\w]'), '_');
    final filename = '${safeName}_photo.jpg';
    try {
      await saveCharacterImage(path, filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.avatarSaveSuccess ?? 'Photo saved')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.avatarSaveError ?? 'Could not save photo'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImageProvider(widget.imagePath);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    // Overlay widgets reused in both the loading and the interactive state.
    final topBar = Positioned(
      top: MediaQuery.of(context).viewPadding.top + 8,
      left: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        style: IconButton.styleFrom(backgroundColor: Colors.black45),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
    final bottomBar = Positioned(
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
              icon: Icons.download_outlined,
              label:
                  AppLocalizations.of(context)?.avatarSavePhoto ?? 'Save photo',
              onTap: _saveToGallery,
            ),
            _ViewerAction(
              icon: Icons.edit_outlined,
              label:
                  AppLocalizations.of(context)?.avatarChangePhoto ??
                  'Change photo',
              onTap: () => Navigator.of(context).pop(_ViewerResult.pick),
            ),
            _ViewerAction(
              icon: Icons.delete_outline,
              label:
                  AppLocalizations.of(context)?.avatarRemovePhoto ??
                  'Remove photo',
              onTap: () => Navigator.of(context).pop(_ViewerResult.remove),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight;

          double fittedW = screenW;
          double fittedH = screenH;
          if (_imageSize != null) {
            final scale = math.min(
              screenW / _imageSize!.width,
              screenH / _imageSize!.height,
            );
            fittedW = _imageSize!.width * scale;
            fittedH = _imageSize!.height * scale;
          }

          // Cache for the live clamp listener (plain assignment, no rebuild).
          _screenW = screenW;
          _screenH = screenH;
          _fittedW = fittedW;
          _fittedH = fittedH;

          // Until image dimensions are loaded and the centering transform is
          // set, show a static BoxFit.contain image (no distortion flash).
          if (!_transformReady) {
            if (_imageSize != null) {
              // Dimensions known; schedule the one-time centering transform.
              final tx = (screenW - fittedW) / 2;
              final ty = (screenH - fittedH) / 2;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_transformReady) {
                  setState(() {
                    _centeredTransform = Matrix4.translationValues(tx, ty, 0);
                    _transformController.value = _centeredTransform;
                    _transformReady = true;
                  });
                }
              });
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: Image(image: image, fit: BoxFit.contain),
                  ),
                ),
                topBar,
                bottomBar,
              ],
            );
          }

          // Interactive viewer.
          // boundaryMargin is huge so InteractiveViewer never restricts
          // movement itself.  _clampTransform() fires on every controller
          // change and enforces the real rules:
          //   scaledDim > screenDim: clamp pan to [screenDim - scaledDim, 0]
          //   scaledDim <= screenDim: center (show black bars on that axis)
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: _isZoomed
                      ? null
                      : (details) {
                          // Close only when tapping the black area around the image.
                          final inv = Matrix4.inverted(
                            _transformController.value,
                          );
                          final childPt = MatrixUtils.transformPoint(
                            inv,
                            details.localPosition,
                          );
                          if (childPt.dx < 0 ||
                              childPt.dx > fittedW ||
                              childPt.dy < 0 ||
                              childPt.dy > fittedH) {
                            Navigator.of(context).pop();
                          }
                        },
                  onDoubleTapDown: _onDoubleTapDown,
                  onDoubleTap: _onDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformController,
                    constrained: false,
                    minScale: 1.0,
                    maxScale: 6.0,
                    boundaryMargin: const EdgeInsets.all(double.maxFinite / 4),
                    child: SizedBox(
                      width: fittedW,
                      height: fittedH,
                      child: Image(image: image, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
              topBar,
              bottomBar,
            ],
          );
        },
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
      ),
    );
  }
}

enum _AvatarAction { pick, delete }

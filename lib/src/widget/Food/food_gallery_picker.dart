import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:app_settings/app_settings.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:path/path.dart' as p;
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class FoodGalleryPicker extends StatefulWidget {
  const FoodGalleryPicker({
    Key? key,
    required this.timeframe,
    required this.timeframeId,
    this.onImagesSelected,
    this.initialSelectedFilePath,
    this.initialSelectedAssetId,
    this.skipPermissionRequest = false,
  }) : super(key: key);

  final String timeframe;
  final String timeframeId;
  final Function(List<String>)? onImagesSelected;
  // When provided, the gallery will pre-select the asset that matches this file path once
  final String? initialSelectedFilePath;
  // Prefer selecting by asset ID when available (more reliable than file path)
  final String? initialSelectedAssetId;
  // When true, skip the PhotoManager permission request flow entirely.
  // Used when navigating from FoodImageCapture after capture, where permission
  // was already granted during initState. On Android 16, re-requesting
  // permission (even just checking state) can trigger the system photo picker.
  final bool skipPermissionRequest;

  @override
  State<FoodGalleryPicker> createState() => _FoodGalleryPickerState();
}

class _FoodGalleryPickerState extends State<FoodGalleryPicker> {
  List<AssetEntity> _recentPhotos = [];
  List<String> _selectedImages = []; // Store photo IDs instead of file paths
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isLimitedPermission = false; // Track if permission is limited
  // Temporary single-select mode. Increase this value in the future to
  // re-enable multi-select behavior without changing the selection flow.
  static const int _selectionLimit = 1;
  int get _maxSelection => _selectionLimit;
  bool get _isSingleSelectionMode => _maxSelection == 1;
  bool _didApplyInitialSelectedPath = false;

  // Pagination variables
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _pageSize = 15; // Load 15 images per page to prevent memory crashes
  bool _isLoadingMore = false;
  bool _hasMorePhotos = true;
  AssetPathEntity? _recentAlbum;
  // Cache thumbnail futures to avoid refetching and flicker on rebuilds
  final Map<String, Future<Uint8List?>> _thumbnailFutures =
      <String, Future<Uint8List?>>{};

  // Flag to prevent infinite retries when gallery is empty
  bool _hasCheckedEmptyGallery = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadPhotos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    // Clear thumbnail cache to free memory
    PhotoManager.clearFileCache();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePhotos();
    }
  }

  Future<void> _requestPermissionAndLoadPhotos() async {
    if (_isDisposed || !mounted) return;

    try {
      if (!mounted) return;
      developer.log(
          '[GALLERY] _requestPermissionAndLoadPhotos - skipPermissionRequest: ${widget.skipPermissionRequest}',
          name: '[GALLERY]');
      setState(() {
        _isLoading = true;
      });

      // When skipPermissionRequest is true (called from FoodImageCapture after
      // capture), permission was already granted. Skip the entire permission
      // request flow — including PhotoManager.requestPermissionExtend() —
      // because on Android 16 calling it with limited access can re-trigger
      // the system photo picker dialog.
      if (widget.skipPermissionRequest) {
        developer.log(
            '[GALLERY] skipPermissionRequest=true, loading photos directly',
            name: '[GALLERY]');
        await _tryLoadPhotosDirectly();
        return;
      }

      // First, try to access photos directly without requesting permission
      // This avoids triggering permission dialog if permission is already granted
      try {
        developer.log(
            '[GALLERY] Attempting direct photo access without permission request...',
            name: '[GALLERY]');
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
        );

        if (albums.isNotEmpty) {
          developer.log(
              '[GALLERY] Direct access succeeded, albums found: ${albums.length}',
              name: '[GALLERY]');

          // Use getPermissionState() instead of requestPermissionExtend()
          // to check limited status without triggering the system picker.
          PermissionState currentState = PermissionState.authorized;
          try {
            currentState = await PhotoManager.getPermissionState(
              requestOption: const PermissionRequestOption(
                androidPermission: AndroidPermission(
                  type: RequestType.image,
                  mediaLocation: false,
                ),
              ),
            );
          } catch (stateError) {
            developer.log(
                '[GALLERY] getPermissionState failed, using default: $stateError',
                name: '[GALLERY]');
          }
          developer.log(
              '[GALLERY] Permission state: $currentState',
              name: '[GALLERY]');

          if (!mounted) return;
          final bool isLimited = currentState == PermissionState.limited;
          setState(() {
            _hasPermission = true;
            _isLimitedPermission = isLimited;
          });

          _recentAlbum = albums.first;
          await _loadPhotosPage(0, isInitialLoad: true);
          return;
        }
      } catch (directAccessError) {
        developer.log(
            '[GALLERY] Direct access failed: $directAccessError',
            name: '[GALLERY]');
      }

      // If direct access failed, request permission
      developer.log(
          '[GALLERY] Requesting permission via requestPermissionExtend()...',
          name: '[GALLERY]');
      final PermissionState currentState =
          await PhotoManager.requestPermissionExtend();
      developer.log(
          '[GALLERY] Permission state after request: $currentState, isAuth: ${currentState.isAuth}, limited: ${currentState == PermissionState.limited}',
          name: '[GALLERY]');

      if (_isDisposed || !mounted) return;

      // Track if permission is limited
      final bool isLimited = currentState == PermissionState.limited;
      if (!mounted) return;
      setState(() {
        _isLimitedPermission = isLimited;
      });

      // On Android 13+, sometimes permission state is incorrectly reported as denied
      // even when permission is actually granted. Let's try to access photos directly.
      // Also, if permission is already granted (authorized/limited), proceed to load photos
      if (currentState == PermissionState.authorized ||
          currentState == PermissionState.limited ||
          currentState.isAuth) {
        developer.log(
            '[GALLERY] Permission appears to be granted, attempting to load photos...',
            name: '[GALLERY]');
      }
      await _tryLoadPhotosDirectly();
    } catch (e) {
      developer.log(
          '[GALLERY] Error in permission process: $e',
          name: '[GALLERY]');
      if (!mounted) return;
      setState(() {
        _hasPermission = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _tryLoadPhotosDirectly() async {
    if (_isDisposed || !mounted || _hasCheckedEmptyGallery) return;

    try {
      print('Attempting to load photos directly...');

      // Try to get albums directly - this will work if permission is actually granted
      // even if the permission state is incorrectly reported as denied
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      print('Direct album access result: ${albums.length} albums found');

      if (albums.isNotEmpty) {
        developer.log(
            '[GALLERY] Direct album access succeeded: ${albums.length} albums',
            name: '[GALLERY]');
        if (!mounted) return;

        // Use getPermissionState() instead of requestPermissionExtend()
        // to check limited status without triggering the system picker.
        final PermissionState currentState = await _getPermissionStateSafe();
        final bool isLimited = currentState == PermissionState.limited;

        setState(() {
          _hasPermission = true;
          _isLoading = false;
          _isLimitedPermission = isLimited;
        });
        _recentAlbum = albums.first;

        // Check if album has any photos before trying to load
        final int assetCount = await _recentAlbum!.assetCountAsync;
        developer.log(
            '[GALLERY] Album has $assetCount photos',
            name: '[GALLERY]');

        if (assetCount == 0) {
          developer.log(
              '[GALLERY] Gallery is empty - no photos to load',
              name: '[GALLERY]');
          if (!mounted) return;
          final PermissionState currentState = await _getPermissionStateSafe();
          final bool isLimited = currentState == PermissionState.limited;
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = true;
            _isLimitedPermission = isLimited;
            _hasCheckedEmptyGallery = true;
          });
          return;
        }

        await _loadPhotosPage(0, isInitialLoad: true);
      } else {
        developer.log(
            '[GALLERY] No albums found - checking permission state...',
            name: '[GALLERY]');
        final PermissionState currentState = await _getPermissionStateSafe();

        if (currentState == PermissionState.limited ||
            currentState == PermissionState.authorized ||
            currentState.isAuth) {
          developer.log(
              '[GALLERY] Permission granted but no albums - gallery is empty',
              name: '[GALLERY]');
          if (!mounted) return;
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = true;
            _hasCheckedEmptyGallery = true;
          });
        } else {
          developer.log(
              '[GALLERY] Permission denied - cannot access gallery',
              name: '[GALLERY]');
          if (!mounted) return;
          setState(() {
            _hasPermission = false;
            _isLoading = false;
            _hasCheckedEmptyGallery = true;
          });
        }
      }
    } catch (e) {
      developer.log(
          '[GALLERY] Error accessing photos directly: $e',
          name: '[GALLERY]');
      if (!mounted) return;

      // On Android 13+, check permission state even if there was an error
      // Sometimes errors occur even when permission is granted
      try {
        final PermissionState currentState = await _getPermissionStateSafe();
        developer.log(
            '[GALLERY] Permission state after error: $currentState',
            name: '[GALLERY]');

        if (currentState == PermissionState.authorized ||
            currentState == PermissionState.limited ||
            currentState.isAuth) {
          developer.log(
              '[GALLERY] Permission is actually granted despite error',
              name: '[GALLERY]');
          setState(() {
            _hasPermission = true;
            _isLoading = false;
            _isLimitedPermission = currentState == PermissionState.limited;
            _hasCheckedEmptyGallery = true;
            _recentPhotos = [];
          });
          return;
        }
      } catch (permissionCheckError) {
        developer.log(
            '[GALLERY] Error checking permission state: $permissionCheckError',
            name: '[GALLERY]');
      }

      setState(() {
        _isLoading = false;
        _hasCheckedEmptyGallery = true;
        _hasPermission = false;
      });
    }
  }

  /// Safe wrapper around getPermissionState() that never triggers a system
  /// dialog. Falls back to PermissionState.denied on any error.
  Future<PermissionState> _getPermissionStateSafe() async {
    try {
      return await PhotoManager.getPermissionState(
        requestOption: const PermissionRequestOption(
          androidPermission: AndroidPermission(
            type: RequestType.image,
            mediaLocation: false,
          ),
        ),
      );
    } catch (e) {
      developer.log(
          '[GALLERY] _getPermissionStateSafe error: $e',
          name: '[GALLERY]');
      return PermissionState.denied;
    }
  }

  Future<void> _handlePermissionDenied() async {
    if (_isDisposed || !mounted || _hasCheckedEmptyGallery) return;

    developer.log(
        '[GALLERY] Handling permission denied state...',
        name: '[GALLERY]');

    _hasCheckedEmptyGallery = true;

    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      developer.log(
          '[GALLERY] Final permission request result: $permission',
          name: '[GALLERY]');

      if (_isDisposed || !mounted) return;

      if (permission == PermissionState.authorized ||
          permission == PermissionState.limited ||
          permission.isAuth) {
        developer.log(
            '[GALLERY] Permission granted on final attempt',
            name: '[GALLERY]');
        if (!mounted) return;
        setState(() {
          _isLimitedPermission = permission == PermissionState.limited;
        });
        _hasCheckedEmptyGallery = false;
        await _tryLoadPhotosDirectly();
        return;
      }
    } catch (e) {
      developer.log(
          '[GALLERY] Error in final permission request: $e',
          name: '[GALLERY]');
    }

    if (_isDisposed || !mounted) return;

    setState(() {
      _hasPermission = false;
      _isLoading = false;
    });
  }

  Future<void> _loadRecentPhotos() async {
    if (_isDisposed || !mounted || _hasCheckedEmptyGallery) return;

    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMorePhotos = true;
      });

      print('Attempting to load photos...');

      // Get recent photos album
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      print('Found ${albums.length} albums');

      if (albums.isNotEmpty) {
        _recentAlbum = albums.first;
        print('Using album: ${_recentAlbum!.name}');

        // Check if album has photos
        final int assetCount = await _recentAlbum!.assetCountAsync;
        if (assetCount == 0) {
          if (!mounted) return;
          // Check permission state to update limited status
          final PermissionState currentState =
              await PhotoManager.requestPermissionExtend();
          final bool isLimited = currentState == PermissionState.limited;
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _isLimitedPermission = isLimited;
            _hasCheckedEmptyGallery = true;
          });
          return;
        }

        await _loadPhotosPage(0, isInitialLoad: true);
      } else {
        print(
            'No albums found - checking if gallery is empty or permission denied');
        if (!mounted) return;

        // Check permission state to determine if it's empty gallery or denied
        final PermissionState currentState =
            await PhotoManager.requestPermissionExtend();

        // If permission is limited or authorized but no albums, treat as empty gallery
        if (currentState == PermissionState.limited ||
            currentState == PermissionState.authorized ||
            currentState.isAuth) {
          print('Permission granted but no albums - gallery is empty');
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = true;
            _isLimitedPermission = currentState == PermissionState.limited;
            _hasCheckedEmptyGallery = true;
          });
        } else {
          // Permission is truly denied
          print('Permission denied - cannot access gallery');
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = false;
            _hasCheckedEmptyGallery = true; // Stop retrying
          });
        }
      }
    } catch (e) {
      print('Error loading photos: $e');
      if (!mounted) return;
      setState(() {
        _recentPhotos = [];
        _isLoading = false;
        _hasCheckedEmptyGallery = true; // Stop retrying on error
        _hasPermission = false;
      });
    }
  }

  Future<void> _loadPhotosPage(int page, {bool isInitialLoad = false}) async {
    if (_recentAlbum == null || _isDisposed || !mounted) return;

    try {
      if (!mounted) return;
      if (isInitialLoad) {
        setState(() {
          _isLoading = true;
        });
      } else {
        setState(() {
          _isLoadingMore = true;
        });
      }

      final List<AssetEntity> photos = await _recentAlbum!.getAssetListPaged(
        page: page,
        size: _pageSize,
      );

      if (!mounted) return;
      setState(() {
        if (isInitialLoad) {
          _recentPhotos = photos;
          _isLoading = false;
        } else {
          _recentPhotos.addAll(photos);
          _isLoadingMore = false;
        }
        _currentPage = page;
        _hasMorePhotos = photos.length == _pageSize;
      });

      // Prefer pre-select by asset ID if provided
      if (isInitialLoad &&
          !_didApplyInitialSelectedPath &&
          widget.initialSelectedAssetId != null &&
          widget.initialSelectedAssetId!.isNotEmpty) {
        final matching =
            photos.where((e) => e.id == widget.initialSelectedAssetId);
        if (matching.isNotEmpty) {
          final match = matching.first;
          if (!mounted) return;
          setState(() {
            if (_trySelectImage(match.id)) {
              _didApplyInitialSelectedPath = true;
            }
          });
        }
      }

      // Only pre-select if a specific file path was provided by the caller
      if (isInitialLoad &&
          !_didApplyInitialSelectedPath &&
          widget.initialSelectedFilePath != null &&
          widget.initialSelectedFilePath!.isNotEmpty) {
        try {
          // Attempt to find the photo matching the given file path within the currently loaded page
          for (final asset in photos) {
            if (_isDisposed || !mounted) return;
            final File? assetFile = await asset.file;
            if (assetFile != null &&
                assetFile.path == widget.initialSelectedFilePath) {
              if (!mounted) return;
              setState(() {
                if (_trySelectImage(asset.id)) {
                  _didApplyInitialSelectedPath = true;
                }
              });
              break;
            }
          }
        } catch (e) {
          // Ignore errors; user can select manually
        }
      }
    } catch (e) {
      print('Error loading photos page: $e');
      if (!mounted) return;
      setState(() {
        if (isInitialLoad) {
          _isLoading = false;
        } else {
          _isLoadingMore = false;
        }
      });
    }
  }

  Future<void> _loadMorePhotos() async {
    if (!_isLoadingMore && _hasMorePhotos && _recentAlbum != null) {
      await _loadPhotosPage(_currentPage + 1);
    }
  }

  /// Handle the "Manage" button press to show system photo picker for limited access
  /// Since the banner only shows when _isLimitedPermission is true, we can safely
  /// call presentLimited() directly without re-checking permission
  Future<void> _handleManageLimitedAccess() async {
    if (_isDisposed || !mounted) return;

    try {
      // Directly present the system UI to manage selection
      // No need to check permission again since banner only shows when limited
      await PhotoManager.presentLimited();
      print('PhotoManager.presentLimited() completed');

      // Reload photos to reflect any new selection made by the user
      if (mounted) {
        print('Refreshing gallery after managing limited photos...');

        // Clear thumbnail cache to force refresh
        _thumbnailFutures.clear();

        // Reload photos to reflect changes
        await _loadRecentPhotos();
      }
    } catch (e) {
      print('Error managing limited access: $e');

      // On Android, presentLimited() might not work, fallback to app settings
      if (Platform.isAndroid) {
        print('Android: Falling back to app settings...');
        await AppSettings.openAppSettings(type: AppSettingsType.settings);

        if (mounted) {
          _showErrorDialog(
              'Vui lòng vào Cài đặt > Quyền > Ảnh và video để quản lý quyền truy cập ảnh.\n\n'
              'Sau khi thay đổi, vui lòng quay lại ứng dụng và làm mới danh sách ảnh.');
        }
      } else {
        if (mounted) {
          _showErrorDialog('Lỗi khi quản lý quyền truy cập: $e');
        }
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 100,
      );

      if (image != null) {
        // Persist captured image to system gallery and select it
        try {
          final bytes = await File(image.path).readAsBytes();
          final String fileName =
              'DiaB_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final AssetEntity? saved = await PhotoManager.editor.saveImage(
            bytes,
            title: fileName,
            filename: fileName,
          );

          // Reload recent photos to include the new capture
          await _loadRecentPhotos();

          if (saved != null && mounted) {
            setState(() {
              _trySelectImage(saved.id);
            });
          }
        } catch (e) {
          // Fallback: reload photos and let user select manually
          await _loadRecentPhotos();
        }
      }
    } catch (e) {
      print('Error capturing image: $e');
      _showErrorDialog('Lỗi khi chụp ảnh: $e');
    }
  }

  void _toggleImageSelection(String imageId) {
    if (!mounted) return;
    setState(() {
      if (_selectedImages.contains(imageId)) {
        _selectedImages.remove(imageId);
      } else {
        _trySelectImage(
          imageId,
          showLimitError: !_isSingleSelectionMode,
        );
      }
    });
  }

  bool _trySelectImage(String imageId, {bool showLimitError = false}) {
    if (_selectedImages.contains(imageId)) {
      return false;
    }

    // In single-select mode, selecting a new image replaces previous selection.
    if (_isSingleSelectionMode) {
      _selectedImages = <String>[imageId];
      return true;
    }

    if (_selectedImages.length < _maxSelection) {
      _selectedImages.add(imageId);
      return true;
    }

    if (showLimitError) {
      _showErrorDialog(
        R.string.max_image_select_dynamic.tr(args: ["${_maxSelection}"]),
      );
    }
    return false;
  }

  /// Convert image to 480x480 JPEG, auto-cropping to center square.
  /// This is especially important on iOS where HEIC / HEIF / Live formats
  /// can cause downstream decoding issues.
  Future<String> _convertToJpeg480x480(String originalPath) async {
    try {
      final File originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return originalPath;
      }

      // Step 1: Use platform codecs (flutter_image_compress) to ensure
      // HEIC/HEIF/LIVE inputs become JPEG bytes.
      final Uint8List? compressedBytes =
          await FlutterImageCompress.compressWithFile(
        originalPath,
        minWidth: 800, // keep some resolution before manual crop
        minHeight: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null || compressedBytes.isEmpty) {
        return originalPath;
      }

      // Step 2: Decode JPEG bytes with `image` package and center-crop to square,
      // then resize to exactly 480x480.
      final img.Image? decoded = img.decodeImage(compressedBytes);
      if (decoded == null) {
        return originalPath;
      }

      final int cropSize =
          decoded.width < decoded.height ? decoded.width : decoded.height;
      final int offsetX = (decoded.width - cropSize) ~/ 2;
      final int offsetY = (decoded.height - cropSize) ~/ 2;

      final img.Image cropped = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: cropSize,
        height: cropSize,
      );

      final img.Image resized =
          img.copyResize(cropped, width: 480, height: 480);

      final List<int> jpegBytes = img.encodeJpg(resized, quality: 85);

      final Directory tempDir = Directory.systemTemp;
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String baseName = p.basenameWithoutExtension(originalPath);
      final String fileName =
          'DiaB_Food_${timestamp}_${baseName.isEmpty ? "image" : baseName}.jpg';
      final File outFile = File(p.join(tempDir.path, fileName));
      await outFile.writeAsBytes(jpegBytes, flush: true);

      developer.log(
        '[CAPTURE] Converted image to JPEG 480x480: ${outFile.path}',
        name: '[CAPTURE]',
      );

      return outFile.path;
    } catch (e) {
      developer.log(
        '[CAPTURE] Error converting image to JPEG 480x480: $e',
        name: '[CAPTURE]',
      );
      // On any error, fall back to the original path so flow continues.
      return originalPath;
    }
  }

  void _confirmSelection() async {
    if (_selectedImages.isNotEmpty) {
      // Convert selected asset IDs to real file paths, robust on iOS
      List<String> filePaths = [];
      for (String photoId in _selectedImages) {
        try {
          AssetEntity? entity = await AssetEntity.fromId(photoId);
          if (entity == null) {
            // Fallback to local list if available
            try {
              entity = _recentPhotos.firstWhere((p) => p.id == photoId);
            } catch (_) {}
          }
          if (entity != null) {
            // On iOS, copy file to persistent location to avoid temporary paths
            // On Android, use the file path directly if it's already accessible
            if (Platform.isIOS) {
              // Get original bytes to ensure we have the full quality image
              Uint8List? imageBytes;
              try {
                imageBytes = await entity.originBytes;
              } catch (e) {
                developer.log('[CAPTURE] iOS: Failed to get originBytes: $e',
                    name: '[CAPTURE]');
              }

              // Fallback: try to get file and read bytes
              if (imageBytes == null) {
                try {
                  File? tempFile = await entity.originFile;
                  tempFile ??= await entity.file;
                  if (tempFile != null && await tempFile.exists()) {
                    imageBytes = await tempFile.readAsBytes();
                  }
                } catch (e) {
                  developer.log('[CAPTURE] iOS: Failed to read file bytes: $e',
                      name: '[CAPTURE]');
                }
              }

              if (imageBytes != null) {
                // Save to temporary directory with a unique name
                final tempDir = Directory.systemTemp;
                final timestamp = DateTime.now().millisecondsSinceEpoch;
                final fileName =
                    'DiaB_Food_${timestamp}_${photoId.substring(0, photoId.length > 8 ? 8 : photoId.length)}.jpg';
                final savedFile = File('${tempDir.path}/$fileName');
                await savedFile.writeAsBytes(imageBytes);

                developer.log(
                    '[CAPTURE] iOS: Copied asset to persistent path: ${savedFile.path}',
                    name: '[CAPTURE]');

                if (await savedFile.exists()) {
                  filePaths.add(savedFile.path);
                }
              } else {
                developer.log(
                    '[CAPTURE] iOS: Failed to get bytes for asset: $photoId',
                    name: '[CAPTURE]');
              }
            } else {
              // Android: Use file path directly
              File? file = await entity.originFile;
              file ??= await entity.file;
              if (file != null && await file.exists()) {
                filePaths.add(file.path);
              }
            }
          }
        } catch (e) {
          developer.log('[CAPTURE] Error processing asset $photoId: $e',
              name: '[CAPTURE]');
          // Skip this asset if it cannot be resolved
        }
      }

      // Normalize all selected images to 480x480 JPEG to avoid issues with
      // HEIC / HEIF / LIVE formats (especially on iOS) and reduce file size.
      if (filePaths.isNotEmpty) {
        final List<String> normalizedPaths = [];
        for (final String path in filePaths) {
          final String convertedPath = await _convertToJpeg480x480(path);
          normalizedPaths.add(convertedPath);
        }
        filePaths = normalizedPaths;
      }

      developer.log(
          '[CAPTURE] Gallery confirm filePaths count: ' +
              filePaths.length.toString() +
              ', paths: ' +
              filePaths.join(', '),
          name: '[CAPTURE]');
      widget.onImagesSelected?.call(filePaths);
      Navigator.pop(context, filePaths);
    } else {
      _showErrorDialog(R.string.please_select_at_least_one_image.tr());
    }
  }

  void _showErrorDialog(String message) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        // width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: R.color.color0xff111515.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: R.color.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      align: Alignment.center,
      duration: Duration(seconds: 2),
      clickClose: true,
      crossPage: true,
      onlyOne: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const SizedBox() // no spinner, check permission silently
                : (_hasPermission
                    ? _buildGalleryContent()
                    : _buildPermissionDenied()),
          ),
          if (_selectedImages.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        R.string.choose_meal_image.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // // Nút "Tìm món ăn"
        // Center(
        //   child: Padding(
        //     padding: const EdgeInsets.only(right: 16.0),
        //     child: GestureDetector(
        //       onTap: _openSearchFood,
        //       child: Container(
        //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //         decoration: BoxDecoration(
        //           color: Color(0xFFCAFAF5),
        //           borderRadius: BorderRadius.circular(12),
        //           border: Border.all(
        //             color: Color(0xFF8FEBE0),
        //             width: 1,
        //           ),
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Icon(
        //               Icons.edit_outlined,
        //               size: 16,
        //               color: R.color.greenGradientBottom,
        //             ),
        //             const SizedBox(width: 4),
        //             Text(
        //               R.string.find_food.tr(),
        //               style: TextStyle(
        //                 color: R.color.greenGradientBottom,
        //                 fontSize: 13,
        //                 fontWeight: FontWeight.w700,
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  /// Mở màn hình tìm kiếm món ăn
  void _openSearchFood() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SearchFoodController(
          foods: [],
          callback: (foods) {
            if (foods.isNotEmpty) {
              Navigator.pushNamed(
                context,
                NavigatorName.confirm_food,
                arguments: {
                  'foods': foods,
                  'timeframe': widget.timeframe,
                  'timeframeId': widget.timeframeId,
                  'files': <String>[],
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // If gallery is empty (checked and confirmed), show empty state with only capture button
    if (_recentPhotos.isEmpty && _hasCheckedEmptyGallery) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Show "Manage" button row if permission is limited
        if (_isLimitedPermission && _hasPermission) _buildLimitedAccessBanner(),
        // Recent photos grid
        Expanded(
          child: _buildPhotosGrid(),
        ),
      ],
    );
  }

  /// Build the "Manage" button banner for limited access
  Widget _buildLimitedAccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: R.color.backgroundColorNew,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              R.string.given_access_gallery_description.tr(),
              style: TextStyle(
                fontSize: 14,
                color: R.color.greenGradientBottom,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _handleManageLimitedAccess,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              R.string.manage.tr(),
              style: TextStyle(
                fontSize: 15,
                color: R.color.greenGradientBottom,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCaptureButton(),
          const SizedBox(height: 16),
          Text(
            'Không có ảnh nào trong thư viện',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    // If gallery is empty, show only capture button
    if (_recentPhotos.isEmpty && _hasCheckedEmptyGallery) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCaptureButton(),
            const SizedBox(height: 16),
            Text(
              'Không có ảnh nào trong thư viện',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      cacheExtent: 600, // pre-cache a bit to smooth scroll
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            3, // Reduced from 4 to 3 for larger items and better performance
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _recentPhotos.length +
          1 +
          (_isLoadingMore
              ? 1
              : 0), // +1 for capture button, +1 for loading indicator
      itemBuilder: (context, index) {
        if (index == 0) {
          // Capture button as first item
          return _buildCaptureButton();
        } else if (index == _recentPhotos.length + 1 && _isLoadingMore) {
          // Loading indicator at the bottom
          return _buildLoadingIndicator();
        } else {
          // Photo items
          final photoIndex = index - 1;
          final photo = _recentPhotos[photoIndex];
          return _buildPhotoItem(photo);
        }
      },
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              R.string.chup_anh.tr(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(AssetEntity photo) {
    final Future<Uint8List?> thumbFuture = _thumbnailFutures[photo.id] ??=
        photo.thumbnailDataWithSize(const ThumbnailSize.square(256));
    return FutureBuilder<Uint8List?>(
      future: thumbFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final thumbnailBytes = snapshot.data!;
          final isSelected = _selectedImages.contains(photo.id);

          return GestureDetector(
            onTap: () => _toggleImageSelection(photo.id),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? R.color.greenGradientBottom
                          : Colors.transparent,
                      width: 2,
                    ),
                    color: Colors.grey[
                        100], // Background color for aspect ratio differences
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      thumbnailBytes,
                      key: ValueKey(photo.id),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover, // center-crop, fill width
                      alignment: Alignment.center, // crop center like gallery
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: R.color.greenGradientBottom,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có quyền truy cập thư viện ảnh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng cấp quyền truy cập thư viện ảnh\nđể sử dụng tính năng này.\n\nTrên Android 13+, bạn có thể chọn:\n• Cho phép truy cập tất cả ảnh\n• Cho phép truy cập một số ảnh',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _requestPermissionAndLoadPhotos();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: R.color.greenGradientBottom,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _confirmSelection,
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientBottom
                      ]),
                  borderRadius: BorderRadius.circular(200),
                ),
                child: Center(
                  child: Text(R.string.tiep_tuc.tr(),
                      style: TextStyle(
                          color: R.color.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

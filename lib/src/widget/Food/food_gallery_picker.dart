import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:app_settings/app_settings.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:photo_manager/photo_manager.dart';

class FoodGalleryPicker extends StatefulWidget {
  const FoodGalleryPicker({
    Key? key,
    required this.timeframe,
    required this.timeframeId,
    this.onImagesSelected,
    this.initialSelectedFilePath,
    this.initialSelectedAssetId,
  }) : super(key: key);

  final String timeframe;
  final String timeframeId;
  final Function(List<String>)? onImagesSelected;
  // When provided, the gallery will pre-select the asset that matches this file path once
  final String? initialSelectedFilePath;
  // Prefer selecting by asset ID when available (more reliable than file path)
  final String? initialSelectedAssetId;

  @override
  State<FoodGalleryPicker> createState() => _FoodGalleryPickerState();
}

class _FoodGalleryPickerState extends State<FoodGalleryPicker> {
  List<AssetEntity> _recentPhotos = [];
  List<String> _selectedImages = []; // Store photo IDs instead of file paths
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isLimitedPermission = false; // Track if permission is limited
  final int _maxSelection = 5;
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
      setState(() {
        _isLoading = true; // show loading while resolving permission
      });
      print('Starting permission and photo loading process...');

      // First, try to access photos directly without requesting permission
      // This avoids triggering permission dialog if permission is already granted
      try {
        print(
            'Attempting to access photos directly without requesting permission...');
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
        );

        if (albums.isNotEmpty) {
          // Successfully accessed photos - permission is already granted
          print('Successfully accessed photos without requesting permission');

          // Now check permission state to determine if it's limited (without requesting)
          // This should not trigger a dialog if permission is already granted
          final PermissionState currentState =
              await PhotoManager.requestPermissionExtend();
          print('Permission state (already granted): $currentState');

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
        // Direct access failed - permission might not be granted
        print(
            'Direct access failed, need to request permission: $directAccessError');
      }

      // If direct access failed, request permission
      print('Requesting permission...');
      final PermissionState currentState =
          await PhotoManager.requestPermissionExtend();
      print('Permission state after request: $currentState');
      print('Permission isAuth: ${currentState.isAuth}');
      print(
          'Permission isAuthorized: ${currentState == PermissionState.authorized}');
      print('Permission isLimited: ${currentState == PermissionState.limited}');

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
        print('Permission appears to be granted, attempting to load photos...');
      }
      await _tryLoadPhotosDirectly();
    } catch (e) {
      print('Error in permission process: $e');
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
        print('Successfully accessed photos - permission is actually granted');
        if (!mounted) return;

        // Check permission state again to update limited status
        final PermissionState currentState =
            await PhotoManager.requestPermissionExtend();
        final bool isLimited = currentState == PermissionState.limited;

        setState(() {
          _hasPermission = true;
          _isLoading = false;
          _isLimitedPermission = isLimited;
        });
        _recentAlbum = albums.first;

        // Check if album has any photos before trying to load
        final int assetCount = await _recentAlbum!.assetCountAsync;
        print('Album has $assetCount photos');

        if (assetCount == 0) {
          // Gallery is empty - stop retrying
          print('Gallery is empty - no photos to load');
          if (!mounted) return;
          // Check permission state to update limited status
          final PermissionState currentState =
              await PhotoManager.requestPermissionExtend();
          final bool isLimited = currentState == PermissionState.limited;
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = true; // Permission is granted, just no photos
            _isLimitedPermission = isLimited;
            _hasCheckedEmptyGallery = true;
          });
          return;
        }

        await _loadPhotosPage(0, isInitialLoad: true);
      } else {
        // No albums found - check permission state to determine if it's empty gallery or denied
        print('No albums found - checking permission state...');
        final PermissionState currentState =
            await PhotoManager.requestPermissionExtend();

        // If permission is limited or authorized but no albums, treat as empty gallery
        if (currentState == PermissionState.limited ||
            currentState == PermissionState.authorized ||
            currentState.isAuth) {
          print('Permission granted but no albums - gallery is empty');
          if (!mounted) return;
          setState(() {
            _recentPhotos = [];
            _isLoading = false;
            _hasPermission = true; // Permission is granted, just no photos
            _hasCheckedEmptyGallery = true;
          });
        } else {
          // Permission is truly denied
          print('Permission denied - cannot access gallery');
          if (!mounted) return;
          setState(() {
            _hasPermission = false;
            _isLoading = false;
            _hasCheckedEmptyGallery = true; // Stop retrying
          });
        }
      }
    } catch (e) {
      print('Error accessing photos directly: $e');
      if (!mounted) return;

      // On Android 13+, check permission state even if there was an error
      // Sometimes errors occur even when permission is granted
      try {
        final PermissionState currentState =
            await PhotoManager.requestPermissionExtend();
        print('Permission state after error: $currentState');

        // If permission is actually granted (authorized, limited, or isAuth),
        // set hasPermission to true even if there was an error accessing photos
        if (currentState == PermissionState.authorized ||
            currentState == PermissionState.limited ||
            currentState.isAuth) {
          print(
              'Permission is actually granted despite error - treating as granted');
          setState(() {
            _hasPermission = true;
            _isLoading = false;
            _isLimitedPermission = currentState == PermissionState.limited;
            _hasCheckedEmptyGallery = true;
            _recentPhotos = []; // Empty list since we couldn't load photos
          });
          return;
        }
      } catch (permissionCheckError) {
        print('Error checking permission state: $permissionCheckError');
      }

      // Mark as checked to prevent infinite retries
      setState(() {
        _isLoading = false;
        _hasCheckedEmptyGallery = true;
        // Only set to false if permission is truly denied
        _hasPermission = false;
      });
    }
  }

  Future<void> _handlePermissionDenied() async {
    if (_isDisposed || !mounted || _hasCheckedEmptyGallery) return;

    print('Handling permission denied state...');

    // Mark as checked to prevent infinite retries
    _hasCheckedEmptyGallery = true;

    // Try one more permission request
    try {
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();
      print('Final permission request result: $permission');

      if (_isDisposed || !mounted) return;

      if (permission == PermissionState.authorized ||
          permission == PermissionState.limited ||
          permission.isAuth) {
        print('Permission granted on final attempt');
        // Update limited permission status
        if (!mounted) return;
        setState(() {
          _isLimitedPermission = permission == PermissionState.limited;
        });
        // Reset the flag to allow one more try
        _hasCheckedEmptyGallery = false;
        await _tryLoadPhotosDirectly();
        return;
      }
    } catch (e) {
      print('Error in final permission request: $e');
    }

    if (_isDisposed || !mounted) return;

    // If we get here, permission is truly denied
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
          if (!_selectedImages.contains(match.id) &&
              _selectedImages.length < _maxSelection) {
            if (!mounted) return;
            setState(() {
              _selectedImages.add(match.id);
              _didApplyInitialSelectedPath = true;
            });
          }
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
              if (!_selectedImages.contains(asset.id) &&
                  _selectedImages.length < _maxSelection) {
                if (!mounted) return;
                setState(() {
                  _selectedImages.add(asset.id);
                  _didApplyInitialSelectedPath = true;
                });
              }
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
              if (!_selectedImages.contains(saved.id) &&
                  _selectedImages.length < _maxSelection) {
                _selectedImages.add(saved.id);
              }
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
      } else if (_selectedImages.length < _maxSelection) {
        _selectedImages.add(imageId);
      } else {
        _showErrorDialog(
            R.string.max_image_select_dynamic.tr(args: ["${_maxSelection}"]));
      }
    });
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

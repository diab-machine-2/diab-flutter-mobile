import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NetWorkImageWidget extends StatelessWidget {
  const NetWorkImageWidget({
    required this.imageUrl,
    this.fallbackImageUrl,
    this.showLoading = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.isSelected = false,
  });

  final String? imageUrl;
  final String? fallbackImageUrl; // For lesson placeholder
  final double? width;
  final double? height;
  final bool showLoading;
  final BoxFit fit;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (fallbackImageUrl != null) {
      return _buildLessonCachedImage();
    } else {
      return _buildCachedImage();
    }
  }

  Widget _buildLessonCachedImage() {
    return LayoutBuilder(builder: (context, constraint) {
      final double? effectiveHeight = height ??
          (constraint.maxHeight.isFinite ? constraint.maxHeight : null);
      final double? effectiveWidth =
          width ?? (constraint.maxWidth.isFinite ? constraint.maxWidth : null);

      final memCacheTarget =
          _memCacheTarget(context, effectiveWidth, effectiveHeight);

      return imageUrl?.isNotEmpty != true
          ? _buildErrorLessonWidget(effectiveWidth, effectiveHeight)
          : CachedNetworkImage(
              width: effectiveWidth,
              height: effectiveHeight,
              imageUrl: imageUrl!,
              color: isSelected ? Colors.white : null,
              fit: fit,
              memCacheWidth: memCacheTarget.width,
              memCacheHeight: memCacheTarget.height,
              placeholder: showLoading
                  ? (_, __) {
                      return Container(color: R.color.transparent);
                    }
                  : null,
              errorWidget: (_, __, ___) {
                return _buildErrorLessonWidget(effectiveWidth, effectiveHeight);
              },
            );
    });
  }

  Widget _buildCachedImage() {
    return LayoutBuilder(builder: (context, constraint) {
      late final double errorIconSize;

      if (width == null || height == null) {
        final double maxW = constraint.maxWidth.isFinite
            ? constraint.maxWidth
            : (width ?? 72.0);
        final double maxH = constraint.maxHeight.isFinite
            ? constraint.maxHeight
            : (width ??
                (constraint.maxWidth.isFinite ? constraint.maxWidth : 72.0));
        errorIconSize = min(maxW, maxH) * 0.5;
      } else {
        errorIconSize = min(width!, height!) * 0.5;
      }
      // Decode size follows the same effective width/height used for the
      // error icon fallback above, scaled to device pixels — keeps
      // CachedNetworkImage from decoding the source image at its full
      // resolution when it's only ever displayed at a much smaller size
      // (banner carousel, news thumbnails, etc).
      final double? memCacheLogicalWidth =
          width ?? (constraint.maxWidth.isFinite ? constraint.maxWidth : null);
      final double? memCacheLogicalHeight = height ??
          (constraint.maxHeight.isFinite ? constraint.maxHeight : null);
      final memCacheTarget = _memCacheTarget(
          context, memCacheLogicalWidth, memCacheLogicalHeight);

      return imageUrl?.isNotEmpty != true
          ? _buildErrorWidget(errorIconSize, constraint)
          : CachedNetworkImage(
              width: width,
              height: height,
              imageUrl: imageUrl!,
              color: isSelected ? Colors.white : null,
              fit: BoxFit.contain,
              memCacheWidth: memCacheTarget.width,
              memCacheHeight: memCacheTarget.height,
              placeholder: showLoading
                  ? (_, __) {
                      return Container(color: R.color.transparent);
                    }
                  : null,
              errorWidget: (_, __, ___) {
                return _buildErrorWidget(errorIconSize, constraint);
              },
            );
    });
  }

  /// Picks a device-pixel memCache target for [CachedNetworkImage], set on
  /// at most ONE axis — never both.
  ///
  /// `cached_network_image` resizes via `ResizeImage.resizeIfNeeded(...)`,
  /// which always uses the default [ResizeImagePolicy.exact] (no way to
  /// select [ResizeImagePolicy.fit] through its public API). Under `exact`,
  /// constraining BOTH width and height decodes the source image to exactly
  /// that box with no aspect-ratio correction — if the box's aspect ratio
  /// doesn't match the source image's, the decoded bitmap comes out
  /// stretched/squished, and no [BoxFit] at the widget layer can undo that
  /// because the pixels are already distorted. Constraining a single axis
  /// lets the engine derive the other proportionally, so the source image
  /// is never distorted — the trade-off is a looser (but still bounded)
  /// memory cap for a source image whose aspect ratio is very different
  /// from the display box's.
  ///
  /// Picks whichever axis is the tighter (smaller) logical constraint, so
  /// the single cap actually applied is the more useful one.
  ({int? width, int? height}) _memCacheTarget(
    BuildContext context,
    double? logicalWidth,
    double? logicalHeight,
  ) {
    final double? validWidth =
        (logicalWidth != null && logicalWidth.isFinite && logicalWidth > 0)
            ? logicalWidth
            : null;
    final double? validHeight =
        (logicalHeight != null && logicalHeight.isFinite && logicalHeight > 0)
            ? logicalHeight
            : null;
    if (validWidth == null && validHeight == null) {
      return (width: null, height: null);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final bool useWidth = validHeight == null ||
        (validWidth != null && validWidth <= validHeight);
    return useWidth
        ? (width: (validWidth! * dpr).round(), height: null)
        : (width: null, height: (validHeight * dpr).round());
  }

  Widget _buildErrorLessonWidget(
      double? effectiveWidth, double? effectiveHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        alignment: Alignment.center,
        height: effectiveHeight,
        width: effectiveWidth,
        color: R.color.main_6,
        child: Image.asset(
          fallbackImageUrl ?? R.drawable.ic_error_lesson_image,
          fit: fit,
          alignment: Alignment.center,
          height: effectiveHeight,
          width: effectiveWidth ?? double.infinity,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(double errorIconSize, BoxConstraints constraint) {
    // Handle unbounded constraints - if height is null and maxHeight is infinite,
    // use width for square aspect ratio, or use maxWidth if width is also null
    final double? effectiveHeight = height ??
        (constraint.maxHeight.isFinite
            ? constraint.maxHeight
            : (width ??
                (constraint.maxWidth.isFinite ? constraint.maxWidth : null)));

    final double? effectiveWidth =
        width ?? (constraint.maxWidth.isFinite ? constraint.maxWidth : null);

    return Container(
      alignment: Alignment.center,
      height: effectiveHeight,
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: R.color.main_6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Image.asset(
        R.drawable.ic_error_image,
        width: errorIconSize,
        height: errorIconSize,
      ),
    );
  }
}

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

      return imageUrl?.isNotEmpty != true
          ? _buildErrorLessonWidget(effectiveWidth, effectiveHeight)
          : CachedNetworkImage(
              width: effectiveWidth,
              height: effectiveHeight,
              imageUrl: imageUrl!,
              color: isSelected ? Colors.white : null,
              fit: fit,
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
      return imageUrl?.isNotEmpty != true
          ? _buildErrorWidget(errorIconSize, constraint)
          : CachedNetworkImage(
              width: width,
              height: height,
              imageUrl: imageUrl!,
              color: isSelected ? Colors.white : null,
              fit: BoxFit.contain,
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

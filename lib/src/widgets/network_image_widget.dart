import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NetWorkImageWidget extends StatelessWidget {
  const NetWorkImageWidget({
    required this.imageUrl,
    this.showLoading = true,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.isSelected = false,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final bool showLoading;
  final BoxFit fit;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
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

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
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final bool showLoading;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      late final double errorIconSize;

      if (width == null || height == null) {
        errorIconSize = min(constraint.maxWidth, constraint.maxHeight) * 0.5;
      } else {
        errorIconSize = min(width!, height!) * 0.5;
      }
      return imageUrl?.isNotEmpty != true
          ? _buildErrorWidget(errorIconSize)
          : CachedNetworkImage(
              width: width,
              height: height,
              imageUrl: imageUrl!,
              fit: fit,
              placeholder: showLoading
                  ? (_, __) {
                      return Container(color: R.color.transparent);
                    }
                  : null,
              errorWidget: (_, __, ___) {
                return _buildErrorWidget(errorIconSize);
              },
            );
    });
  }

  Widget _buildErrorWidget(double errorIconSize) {
    return Container(
      alignment: Alignment.center,
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

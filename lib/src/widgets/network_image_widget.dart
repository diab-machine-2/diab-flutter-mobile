import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class NetWorkImageWidget extends StatelessWidget {
  const NetWorkImageWidget({
    required this.imageUrl,
    this.showLoading = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
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
      final double? effectiveHeight = height ??
          (constraint.maxHeight.isFinite ? constraint.maxHeight : null);
      final double? effectiveWidth = width ??
          (constraint.maxWidth.isFinite ? constraint.maxWidth : null);

      return imageUrl?.isNotEmpty != true
          ? _buildErrorWidget(effectiveWidth, effectiveHeight)
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
                return _buildErrorWidget(effectiveWidth, effectiveHeight);
              },
            );
    });
  }

  Widget _buildErrorWidget(double? effectiveWidth, double? effectiveHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        alignment: Alignment.center,
        height: effectiveHeight,
        width: effectiveWidth,
        color: R.color.main_6,
        child: Image.asset(
          R.drawable.ic_error_image,
          fit: fit,
          alignment: Alignment.center,
          height: effectiveHeight,
          width: effectiveWidth ?? double.infinity,
        ),
      ),
    );
  }
}

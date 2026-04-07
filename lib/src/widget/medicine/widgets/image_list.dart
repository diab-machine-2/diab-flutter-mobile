import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../modal/medicine/image_note_model.dart';
import '../../../utils/const.dart';

class ImageList extends StatelessWidget {
  final List<ImageNoteModel> images;

  const ImageList({Key? key, required this.images}) : super(key: key);

  String _buildFullUrl(String id) {
    if (Const.ENVIRONMENT_DEFAULT == 'product') {
      return Uri.https(Const.DOMAIN, 'App/Image/$id').toString();
    } else if (Const.ENVIRONMENT_DEFAULT == 'staging') {
      return Uri.https(Const.DOMAIN_STAGING, 'App/Image/$id').toString();
    } else {
      return Uri.https(Const.DOMAIN_DEV, 'App/Image/$id').toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final fullUrl = _buildFullUrl(images[index].id);

          return GestureDetector(
            onTap: () => _openPreview(context, fullUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: fullUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 24, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Mở preview ảnh fullscreen
  void _openPreview(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullImagePreview(url: url),
      ),
    );
  }
}

class _FullImagePreview extends StatelessWidget {
  final String url;

  const _FullImagePreview({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(), // chạm ra ngoài để đóng
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

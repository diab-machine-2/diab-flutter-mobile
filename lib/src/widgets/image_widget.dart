import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class ImageWidget extends StatelessWidget {

  final String? url;
  final Widget? placeholder;
  const ImageWidget({Key? key, required this.url, this.placeholder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: url ?? "",
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (context, url, _) =>
        placeholder ?? Container(color: R.color.white),
        placeholder: (context, url) =>
            placeholder ?? Container(color: R.color.white),
      ),
    );
  }
}

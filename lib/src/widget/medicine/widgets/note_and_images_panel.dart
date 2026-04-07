import 'package:flutter/material.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/image_note_model.dart';
import 'image_list.dart';

class NoteAndImagesPanel extends StatelessWidget {
  const NoteAndImagesPanel({super.key, this.note, this.images});

  final String? note;
  final List<ImageNoteModel>? images;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF4F7F7),
        borderRadius: BorderRadius.circular(16),
      ),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Ghi chú: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: R.color.color0xff5E6566,
                  ),
                ),
                TextSpan(
                  text: note ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: R.color.color0xff5E6566,
                  ),
                ),
              ],
            ),
          ),
          if ((images ?? []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: ImageList(images: images!),
            ),
        ],
      ),
    );
  }
}

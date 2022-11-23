import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class ButtonAddPhoto extends StatelessWidget {
  const ButtonAddPhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      dashPattern: [4, 5],
      strokeWidth: 1,
      padding: EdgeInsets.all(3),
      radius: Radius.circular(5),
      color: R.color.mainColor,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 20,
              color: R.color.mainColor,
            ),
            SizedBox(height: 10),
            AutoSizeText(
              R.string.add_photo.tr(),
              maxLines: 1,
              minFontSize: 10,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: R.color.mainColor,
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        ),
      ),
    );
  }
}

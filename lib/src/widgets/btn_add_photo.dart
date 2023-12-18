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
      dashPattern: [3, 4],
      strokeWidth: 2,
      padding: EdgeInsets.all(3),
      radius: Radius.circular(12),
      color: R.color.mainColor,
      child: Center(
        child: Container(
          height: 80,
          width: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 24,
                  color: R.color.mainColor,
                ),
                SizedBox(height: 5),
                AutoSizeText(
                  R.string.add_photo.tr(),
                  maxLines: 1,
                  minFontSize: 10,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: R.color.mainColor,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesEmptyWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color? titleColor;

  const DsmesEmptyWidget({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 130,
            height: 95,
          ),
          if (title.isNotEmpty) GapH(16),
          if (title.isNotEmpty)
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: titleColor ?? R.color.color0xffBFC6C6,
              ),
            ),
          if (subtitle.isNotEmpty) GapH(8),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: R.color.color0xffBFC6C6,
              ),
            ),
        ],
      ),
    );
  }
}

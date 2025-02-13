import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BookingClinicEmptyWidget extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color? titleColor;

  const BookingClinicEmptyWidget({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GapH(100),
              Image.asset(
                imagePath,
                width: 237,
                height: 171,
              ),
              if (title.isNotEmpty) GapH(16),
              if (title.isNotEmpty)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: titleColor ?? R.color.color0xff636A6B,
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
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildButton(),
        ),
      ],
    );
  }

  _buildButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: R.color.white,
          boxShadow: [Utils.getBoxShadowDropButton()],
        ),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
            ),
            borderRadius: BorderRadius.circular(200),
          ),
          child: Text(
            R.string.support.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.white,
            ),
          ),
        ),
      ),
    );
  }
}

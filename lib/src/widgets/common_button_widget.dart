import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CommomButtonWidget extends StatelessWidget {
  const CommomButtonWidget(this.onTap);
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: SafeArea(
        top: false,
        child: Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            height: 48,
            width: 195,
            decoration: BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientBottom
                    ])),
            child: Center(
                child: Text(R.string.save.tr(),
                    style: TextStyle(
                        color: R.color.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)))),
      ),
    );
  }
}

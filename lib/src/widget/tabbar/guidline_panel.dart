import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';

class GuidlinePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Center(
                child: Container(
                  height: 3.86,
                  width: 60,
                  decoration: BoxDecoration(color: R.color.color0xffE5E5E5),
                ),
              ),
              SizedBox(height: 27),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(R.string.your_status_info.tr(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  // Container(
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 24,
                      width: 24,
                      child: Image.asset(R.drawable.ic_close),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(R.string.warning_info.tr(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(R.string.tends_to_negative.tr(),
                    style: TextStyle(fontSize: 14)),
                Image.asset(R.drawable.ic_angry, width: 24, height: 24)
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(R.string.not_changeed.tr(), style: TextStyle(fontSize: 14)),
                      Image.asset(R.drawable.ic_sad,
                          width: 24, height: 24)
                    ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(R.string.tends_to_posiitive.tr(),
                    style: TextStyle(fontSize: 14)),
                Image.asset(R.drawable.ic_happy, width: 24, height: 24)
              ]),
              SizedBox(height: 27),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(R.string.good_successed.tr(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Image.asset(R.drawable.ic_coin, width: 24, height: 24)
              ]),
              SizedBox(height: 27),
            ]),
      ),
    ));
  }
}

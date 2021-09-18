import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

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
                  Text('Trạng thái chỉ số của bạn',
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
                      child: Image.asset(R.drawable.x_icon),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text('Các chỉ số ở mức cảnh báo:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Có xu hướng trở nên tiêu cực',
                    style: TextStyle(fontSize: 14)),
                Image.asset(R.drawable.angry, width: 24, height: 24)
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Không thay đổi', style: TextStyle(fontSize: 14)),
                      Image.asset(R.drawable.sad,
                          width: 24, height: 24)
                    ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Có xu hướng trở nên tích cực',
                    style: TextStyle(fontSize: 14)),
                Image.asset(R.drawable.happy, width: 24, height: 24)
              ]),
              SizedBox(height: 27),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Tốt / đạt mục tiêu',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Image.asset(R.drawable.coin, width: 24, height: 24)
              ]),
              SizedBox(height: 27),
            ]),
      ),
    ));
  }
}

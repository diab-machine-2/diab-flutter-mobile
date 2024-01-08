import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../res/R.dart';

class FoodTrendChartTabBar extends StatefulWidget {
  Function() onEnergyTap;
  Function() onCarbTap;

  FoodTrendChartTabBar({required this.onEnergyTap, required this.onCarbTap});
  @override
  FoodTrendChartTabBarState createState() => FoodTrendChartTabBarState();
}

class FoodTrendChartTabBarState extends State<FoodTrendChartTabBar> {

  bool isEnergyTab = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = true;
                });
                widget.onEnergyTap();
              },
              child: Container(
                  height: 32,
                  width: 135,
                  padding: EdgeInsets.only(left: 18, right: 18),
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.mainColor : R.color.transparent,
                      border: Border.all(
                          color: isEnergyTab
                              ? R.color.mainColor
                              : R.color.primaryGreyColor,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(R.string.nang_luong.tr(),
                        style: TextStyle(
                            color:
                                isEnergyTab ? R.color.white : R.color.primaryGreyColor,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  )),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  isEnergyTab = false;
                });
                widget.onCarbTap();
              },
              child: Container(
                  height: 32,
                  width: 135,
                  decoration: BoxDecoration(
                      color:
                          isEnergyTab ? R.color.transparent : R.color.mainColor,
                      border: Border.all(
                          color: isEnergyTab ? R.color.primaryGreyColor : R.color.white,
                          width: 0.5),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(R.string.chat_bot_duong.tr(),
                        style: TextStyle(
                            color:
                                isEnergyTab ? R.color.primaryGreyColor : R.color.white,
                            fontSize: 14,
                            fontWeight: isEnergyTab
                                ? FontWeight.w400
                                : FontWeight.w700)),
                  )),
            )
          ]);
  }
}
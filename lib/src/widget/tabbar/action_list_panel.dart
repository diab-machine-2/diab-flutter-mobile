import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/Exercrises/exercrise_onboarding.dart';

class ActionListPanel extends StatelessWidget {
  ActionListPanel({required this.selectedIndex});
  final int selectedIndex;

  final data = [
    {
      'name': R.string.hba1c.tr(),
      'icon': R.drawable.ic_hba1c,
    },
    {
      'name': R.string.duong_huyet.tr(),
      'icon': R.drawable.ic_glucose,
    },
    {
      'name': R.string.huyet_ap.tr(),
      'icon': R.drawable.ic_blood_pressure,
    },
    {
      'name': R.string.van_dong.tr(),
      'icon': R.drawable.ic_exercise,
    },
    {
      'name': R.string.dinh_duong.tr(),
      'icon': R.drawable.ic_food_action,
    },
    {
      'name': R.string.can_nang.tr(),
      'icon': R.drawable.ic_weight,
    },
    // {
    //   'name': R.string.cam_xuc.tr(),
    //   'icon': R.drawable.ic_emotion,
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Scaffold(
            backgroundColor: R.color.transparent,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16))),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 16),
                          child: Row(children: [
                            Icon(Icons.close, color: R.color.black),
                            SizedBox(width: 16),
                            Text(R.string.choose_other_info.tr(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: R.color.black,
                                    fontWeight: FontWeight.w700))
                          ]),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(0),
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return buildItem(context, index,
                                  data[index]['name']!, data[index]['icon']!);
                            })
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget buildItem(BuildContext context, int index, String name, String icon) {
    return GestureDetector(
      onTap: () async {
        bool hasExerciseData = false;
        bool hasGlucoseData = false;

        if (index == 1) {
          hasGlucoseData = await HomeClient().fetchHomes().then((data) {
            return data.glucoseIndex.index != null && data.glucoseIndex.index! > 0;
          });
        } else if (index == 3) {
          hasExerciseData = await HomeClient().fetchHomes().then((data) {
            return data.exercise?.isDataNotEmpty ?? false;
          });
        }

        Navigator.pop(context);
        if (selectedIndex == index) {
          return;
        }
        if (index == 0) {
          Navigator.pushReplacementNamed(context, NavigatorName.detail_hba1c);
        } else if (index == 1) {
          if (hasGlucoseData) {
            Navigator.pushReplacementNamed(
                context, NavigatorName.detail_blood_sugar);
          } else {
            Navigator.pushReplacementNamed(
                context, NavigatorName.glucose_intro_1st_page);
          }
        } else if (index == 2) {
          Navigator.pushReplacementNamed(
              context, NavigatorName.detail_blood_pressure);
        } else if (index == 3) {
          if (hasExerciseData) {
            showActivityInputMethodSelection(hasExerciseData: hasExerciseData);
          } else {
            Navigator.pushReplacementNamed(
                context, NavigatorName.exercrise_onboarding);
          }
        } else if (index == 4) {
          Navigator.pushReplacementNamed(context, NavigatorName.detail_food);
        } else if (index == 5) {
          Navigator.pushReplacementNamed(context, NavigatorName.detail_bmi);
        }
        // else if (index == 6) {
        //   Navigator.pushReplacementNamed(context, NavigatorName.detail_emotion);
        // }
      },
      child: Container(
          height: 74,
          color: selectedIndex == index ? R.color.main_6 : R.color.white,
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(icon, width: 36, height: 36),
                  SizedBox(width: 16),
                  Text(name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selectedIndex == index
                              ? R.color.mainColor
                              : R.color.grey_1)),
                ],
              ),
              selectedIndex == index
                  ? Image.asset(R.drawable.ic_check_mark_bg,
                      width: 20, height: 20)
                  : SizedBox(),
            ],
          )),
    );
  }
}

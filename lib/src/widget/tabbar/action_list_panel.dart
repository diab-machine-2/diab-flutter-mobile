import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';

class ActionListPanel extends StatelessWidget {
  ActionListPanel({@required this.selectedIndex});
  final int selectedIndex;

  final data = [
    {
      'name': 'HbA1C',
      'icon': 'assets/images/ic_hba1c.png',
    },
    {
      'name': 'Đường huyết',
      'icon': 'assets/images/ic_glucose.png',
    },
    {
      'name': 'Huyết áp',
      'icon': 'assets/images/ic_blood_pressure.png',
    },
    {
      'name': 'Vận động',
      'icon': 'assets/images/ic_excersire.png',
    },
    {
      'name': 'Dinh dưỡng',
      'icon': 'assets/images/ic_food_action.png',
    },
    {
      'name': 'Cân nặng',
      'icon': 'assets/images/ic_weight.png',
    },
    {
      'name': 'Cảm xúc',
      'icon': 'assets/images/ic_emotion.png',
    },
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
                            Text('Chọn chỉ số khác',
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
                                  data[index]['name'], data[index]['icon']);
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
      onTap: () {
        Navigator.pop(context);
        if (selectedIndex == index) {
          return;
        }
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/detail_hba1c');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/detail_bloodSugar');
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/detail_bloodPressure');
        } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/detail_exercrises');
        } else if (index == 4) {
          Navigator.pushReplacementNamed(context, '/detail_food');
        } else if (index == 5) {
          Navigator.pushReplacementNamed(context, '/detail_bmi');
        } else if (index == 6) {
          Navigator.pushReplacementNamed(context, '/detail_emotion');
        }
      },
      child: Container(
          height: 74,
          color: selectedIndex == index ? R.color.color0xFFE4F5F5 : R.color.white,
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
                              : R.color.color0xff454649)),
                ],
              ),
              selectedIndex == index
                  ? Image.asset('assets/images/check_mark_bg.png',
                      width: 20, height: 20)
                  : SizedBox(),
            ],
          )),
    );
  }
}

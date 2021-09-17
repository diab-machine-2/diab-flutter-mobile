import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/exercrises/exercrises_intensity.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/Food/widget/intensity_food.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/widget/helper/show_message.dart';

typedef NumCallback = Function(double);

class CalculatorTDEEFood extends StatefulWidget {
  final NumCallback callback;

  CalculatorTDEEFood({this.callback});
  @override
  CalculatorTDEEFoodState createState() => CalculatorTDEEFoodState();
}

class CalculatorTDEEFoodState extends State<CalculatorTDEEFood> {
  int selectedWeight = 0;
  int selectedHeight = 0;
  int selectedYear = 0;
  ExercriseIntensityModel intensity;
  @override
  void initState() {
    super.initState();
    selectedWeight = (AppSettings.userInfo.weight ?? 0).toInt();
    selectedHeight = (AppSettings.userInfo.height ?? 0).toInt();
    selectedYear = DateTime.fromMillisecondsSinceEpoch(
            AppSettings.userInfo.dateOfBirth * 1000)
        .year;
    loadData();
  }

  loadData() async {
    BotToast.showLoading();
    final result = await FoodClient().fetchIntensity();
    intensity = result.length == 0 ? null : result.first;
    BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: R.color.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tính theo TDEE',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                    // padding: EdgeInsets.only(right: 30),
                                    icon: Icon(Icons.close, color: R.color.grey),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Text('Cân nặng',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 40),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  barrierColor:
                                                      Color(0xff003F38)
                                                          .withOpacity(0.5),
                                                  context: context,
                                                  builder: (_) =>
                                                      CustomNumPicker(
                                                          callback: (number) {
                                                            setState(() {
                                                              selectedWeight =
                                                                  number;
                                                            });
                                                          },
                                                          title:
                                                              'Nhập cân nặng',
                                                          max: 200,
                                                          numberDefault:
                                                              selectedWeight ==
                                                                      0
                                                                  ? 50
                                                                  : selectedWeight,
                                                          unit: 'kg'),
                                                );
                                              },
                                              child: Container(
                                                  width: 120,
                                                  child: Center(
                                                    child: Text(
                                                        selectedWeight == 0
                                                            ? '--'
                                                            : selectedWeight
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: selectedWeight ==
                                                                    0
                                                                ? Color(
                                                                    0xff9C9C9C)
                                                                : textDark,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  )),
                                            ),
                                            Container(
                                                height: 1,
                                                width: 100,
                                                color: Color(0xffE5E5E5))
                                          ],
                                        ),
                                        Text('kg',
                                            style: TextStyle(
                                              fontSize: 16,
                                            )),
                                        SizedBox(
                                          width: 26,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Text('Chiều cao',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 40),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  barrierColor:
                                                      Color(0xff003F38)
                                                          .withOpacity(0.5),
                                                  context: context,
                                                  builder: (_) =>
                                                      CustomNumPicker(
                                                          callback: (number) {
                                                            setState(() {
                                                              selectedHeight =
                                                                  number;
                                                            });
                                                          },
                                                          title:
                                                              'Nhập chiều cao',
                                                          max: 300,
                                                          numberDefault:
                                                              selectedHeight ==
                                                                      0
                                                                  ? 160
                                                                  : selectedHeight,
                                                          unit: 'cm'),
                                                );
                                              },
                                              child: Container(
                                                  width: 120,
                                                  child: Center(
                                                    child: Text(
                                                        selectedHeight == 0
                                                            ? '--'
                                                            : selectedHeight
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: selectedHeight ==
                                                                    0
                                                                ? Color(
                                                                    0xff9C9C9C)
                                                                : textDark,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  )),
                                            ),
                                            Container(
                                                height: 1,
                                                width: 100,
                                                color: Color(0xffE5E5E5))
                                          ],
                                        ),
                                        Text('cm',
                                            style: TextStyle(
                                              fontSize: 16,
                                            )),
                                        SizedBox(
                                          width: 22,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Text('Năm sinh',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 40),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  barrierColor:
                                                      Color(0xff003F38)
                                                          .withOpacity(0.5),
                                                  context: context,
                                                  builder: (_) =>
                                                      CustomNumPicker(
                                                          callback: (number) {
                                                            setState(() {
                                                              selectedYear =
                                                                  number;
                                                            });
                                                          },
                                                          title:
                                                              'Nhập năm sinh',
                                                          max: DateTime.now()
                                                              .year,
                                                          numberDefault:
                                                              selectedYear == 0
                                                                  ? 1970
                                                                  : selectedYear,
                                                          unit: 'năm'),
                                                );
                                              },
                                              child: Container(
                                                  width: 120,
                                                  child: Center(
                                                    child: Text(
                                                        selectedYear == 0
                                                            ? '--'
                                                            : selectedYear
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: selectedYear ==
                                                                    0
                                                                ? Color(
                                                                    0xff9C9C9C)
                                                                : textDark,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500)),
                                                  )),
                                            ),
                                            Container(
                                                height: 1,
                                                width: 100,
                                                color: Color(0xffE5E5E5))
                                          ],
                                        ),
                                        SizedBox(
                                          width: 48,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 16, right: 16, top: 24, bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cường độ tập luyện',
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          barrierColor: Color(0xff003F38)
                                              .withOpacity(0.5),
                                          context: context,
                                          builder: (_) =>
                                              ActionListIntensityFood(
                                                  selected: intensity,
                                                  callback: (data) {
                                                    setState(() {
                                                      intensity = data;
                                                    });
                                                  }));
                                    },
                                    child: Container(
                                      color: R.color.transparent,
                                      child: Column(children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(intensity == null
                                                ? 'Chọn cường độ tập luyện'
                                                : intensity.note),
                                            Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 17,
                                              color: textDark,
                                            )
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Container(
                                            height: 1, color: Color(0xffE5E5E5))
                                      ]),
                                    ),
                                  )
                                ],
                              )),
                          Container(
                            margin: EdgeInsets.only(top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        height: 43,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: grayBorder),
                                        child: Center(
                                          child: Text('Huỷ',
                                              style: TextStyle(
                                                  color: textDark,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      getCalo();
                                    },
                                    child: Container(
                                      height: 43,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              greenGradientTop,
                                              greenGradientBottom
                                            ]),
                                        borderRadius:
                                            BorderRadius.circular(200),
                                      ),
                                      child: Center(
                                        child: Text('Tiếp tục',
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ]),
                          )
                        ]),
                  ),
                ))));
  }

  getCalo() async {
    if (selectedWeight == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập cân nặng');
      return;
    }
    if (selectedHeight == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập cân nặng');
      return;
    }
    if (selectedYear == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập cân nặng');
      return;
    }
    if (intensity == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn cường độ tập luyện');
      return;
    }
    BotToast.showLoading();
    try {
      final number = await FoodClient().fetchTDEE(
          selectedWeight, selectedHeight, selectedYear, intensity.id);
      widget.callback(number);
      UserClient().fetchUser();
      Navigator.pop(context);
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/Food/widget/calculator_TDEE.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

typedef NumCallback = Function(int);

class AddTargetFood extends StatefulWidget {
  final int goal;
  final NumCallback callback;
  AddTargetFood({this.goal, this.callback});
  @override
  AddTargetFoodState createState() => AddTargetFoodState();
}

class AddTargetFoodState extends State<AddTargetFood> {
  TextEditingController controller = TextEditingController();
  int selectedCalo = 0;
  @override
  void initState() {
    super.initState();
    selectedCalo = widget.goal;
    controller.text = selectedCalo.toString();
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
                                Text('Năng lượng nạp / ngày',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                IconButton(
                                    // padding: EdgeInsets.only(right: 30),
                                    icon: Icon(Icons.close, color: Colors.grey),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Column(children: [
                                      SizedBox(
                                        width: 140,
                                        child: CupertinoTextField(
                                          controller: controller,
                                          decoration: BoxDecoration(
                                              color: R.color.transparent),
                                          textAlign: TextAlign.center,
                                          enableInteractiveSelection: false,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                RegExp(r'[-.]'))
                                          ],
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 34,
                                              fontWeight: FontWeight.w700),
                                          placeholder: '--',
                                          placeholderStyle: TextStyle(
                                              color: R.color.black,
                                              fontSize: 34,
                                              fontWeight: FontWeight.w500),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedCalo = (value == null ||
                                                      value.isEmpty)
                                                  ? 0
                                                  : int.parse(value);
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                          height: 1,
                                          width: 72,
                                          color: Color(0xffDDDDDD))
                                    ]),
                                    Text('kcal',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                    SizedBox(
                                      width: 16,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
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
                                      FocusScope.of(context).unfocus();
                                      if (selectedCalo == 0) {
                                        Message.showToastMessage(
                                            context, 'Bạn chưa nhập giá trị');
                                        return;
                                      }
                                      widget.callback(selectedCalo.toInt());
                                      Navigator.pop(context);
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
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    height: 1,
                                    width: 88,
                                    color: Color(0xffE5E5E5)),
                                SizedBox(width: 16),
                                Text('Hoặc'),
                                SizedBox(width: 16),
                                Container(
                                    height: 1,
                                    width: 88,
                                    color: Color(0xffE5E5E5))
                              ]),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                barrierColor:
                                    Color(0xff003F38).withOpacity(0.5),
                                context: context,
                                builder: (_) =>
                                    CalculatorTDEEFood(callback: (number) {
                                  setState(() {
                                    selectedCalo = number.round();
                                  });
                                }),
                              );
                            },
                            child: Container(
                              color: R.color.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Tính lại theo công thức TDEE',
                                      style: TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Icon(Icons.arrow_forward, color: mainColor)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                        ]),
                  ),
                ))));
  }
}

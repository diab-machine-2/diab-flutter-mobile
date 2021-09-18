import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
// import 'package:horizontal_card_pager/card_item.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/card_horizontal/card_horizontal.dart';
import 'package:medical/src/widget/components/card_horizontal/card_item.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/src/modal/error/error_model.dart';

typedef EmotionCallback = Function(EmotionModel);

class AddEmoController extends StatefulWidget {
  final String type;
  final EmotionModel emotion;
  final EmotionCallback callback;

  AddEmoController({this.type, this.emotion, this.callback});
  @override
  _AddEmoControllerState createState() => _AddEmoControllerState();
}

class _AddEmoControllerState extends BaseState<AddEmoController> {
  bool isClicked = false;
  EmotionModel selectedEmotion;

  List<EmotionModel> model = [];

  ShortGuiModel des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      selectedEmotion = widget.emotion;
    }
    loadData();
    loadDescription();
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    try {
      BotToast.showLoading();
      model = await EmotionClient().fetchEmotion();
      if (widget.emotion == null) {
        final initIndex = (model.length / 2).round() - 1;
        selectedEmotion = model[initIndex];
      } else {
        selectedEmotion = widget.emotion;
      }

      BotToast.closeAllLoading();

      setState(() {});
    } catch (_) {}
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor:  R.color.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.background_splash),
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(
                    widget.type == 'update'
                        ? 'Chỉnh sửa cảm xúc'
                        : 'Nhập cảm xúc',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                actions: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isClicked = !isClicked;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: isClicked
                          ? Image.asset(R.drawable.help_circle_active,
                              width: 24, height: 24)
                          : Image.asset(R.drawable.help_circle,
                              width: 24, height: 24),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      // height:
                      //     (MediaQuery.of(context).size.width) * 153 / 343 + 16,
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: isClicked
                          ? Description(
                              input: true,
                              data: des,
                              titleDetail: 'Kiểm soát cảm xúc bệnh tiểu đường')
                          : SizedBox(),
                    ),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Center(
                            child: Text('Hôm nay bạn\ncảm thấy thế nào?',
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                                'Trượt sang trái hoặc phải để chọn 1 cảm xúc',
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                          ),
                          SizedBox(height: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              model.length == 0
                                  ? SizedBox()
                                  : HorizontalCardPager(
                                      initialPage: model.lastIndexWhere(
                                          (element) =>
                                              element.id == selectedEmotion.id),
                                      onPageChanged: (page) {
                                        setState(() {
                                          selectedEmotion = model[page.toInt()];
                                        });
                                      },
                                      items:
                                          List.generate(model.length, (index) {
                                        return ImageCarditem(
                                          image: Container(
                                            height: 100,
                                            width: 100,
                                            padding: EdgeInsets.all(
                                                selectedEmotion.id ==
                                                        model[index].id
                                                    ? 0
                                                    : 12),
                                            //color: R.color.red,
                                            child: Image.network(
                                              model[index].imageUrl ?? '',
                                              // width: selectedEmotion.id ==
                                              //         model[index].id
                                              //     ? 100
                                              //     : 36,
                                              // height: selectedEmotion.id ==
                                              //         model[index].id
                                              //     ? 100
                                              //     : 36,
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                              SizedBox(height: 20),
                              Text(
                                model.length == 0
                                    ? ''
                                    : selectedEmotion.vietnameseName,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (widget.type == 'input') {
                    Navigator.pushNamed(context, '/add_symbo', arguments: {
                      'type': 'input',
                      'emotion': selectedEmotion,
                    });
                  } else {
                    widget.callback(selectedEmotion);
                    Navigator.pop(context);
                  }
                },
                child: SafeArea(
                  top: false,
                  child: Container(
                      margin: EdgeInsets.all(16),
                      height: 48,
                      width: 195,
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                      child: Center(
                          child: Text(
                              widget.type == 'input' ? 'Tiếp tục' : 'Cập nhật',
                              style: TextStyle(
                                  color: R.color.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

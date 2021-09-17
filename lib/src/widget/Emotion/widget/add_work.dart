import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/emotion/activity_model.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/modal/emotion/symptom_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Emotion/widget/tags/item_tags_custom.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';

typedef ActivityCallback = Function(List<ActivityModel>, String);

class AddWorkController extends StatefulWidget {
  final String type;
  final EmotionModel emotion;
  final List<SymptomModel> symptoms;
  final List<ActivityModel> activities;
  final String otherSymptom;
  final String otherActivity;
  final ActivityCallback callback;

  AddWorkController(
      {this.type,
      this.emotion,
      this.symptoms,
      this.activities,
      this.callback,
      this.otherSymptom,
      this.otherActivity});
  @override
  _AddWorkControllerState createState() => _AddWorkControllerState();
}

class _AddWorkControllerState extends BaseState<AddWorkController> {
  bool isClicked = false;
  List<ActivityModel> model = [];
  List<ActivityModel> selectedModel = [];
  String otherActivity;

  ShortGuiModel des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      selectedModel = widget.activities;
      otherActivity = widget.otherActivity;
    }
    loadData();
    loadDescription();
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    BotToast.showLoading();
    model = await EmotionClient().fetchActivity();
    BotToast.closeAllLoading();

    setState(() {});
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
        backgroundColor: backgroundColor,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/background_splash.png'),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                    widget.type == 'update'
                        ? 'Chỉnh sửa cảm xúc'
                        : 'Nhập cảm xúc',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textDark)),
                leadingIcon: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    icon: Icon(Icons.arrow_back, color: textDark),
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
                          ? Image.asset('assets/images/help_circle_active.png',
                              width: 24, height: 24)
                          : Image.asset('assets/images/help_circle.png',
                              width: 24, height: 24),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    isClicked
                        ? Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Description(
                                input: true,
                                data: des,
                                titleDetail:
                                    'Kiểm soát cảm xúc bệnh tiểu đường'),
                          )
                        : SizedBox(),
                    Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: Text(
                            'Bạn đã làm gì\ntrong ngày?',
                            style: TextStyle(
                                color: textDark,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                              'Nhấn \'Tiếp tục\' nếu bạn không có hoạt động nào',
                              style: TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Tags(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.start,
                            spacing: 16,
                            runSpacing: 16,
                            horizontalScroll: false,
                            itemCount: model.length + 1,
                            itemBuilder: (index) {
                              return _buildItem(index);
                            },
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (widget.type == 'input') {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add_insight', arguments: {
                      'type': 'input',
                      'emotion': widget.emotion,
                      'symptoms': widget.symptoms,
                      'activities': selectedModel,
                      'otherSymptom': widget.otherSymptom,
                      'otherActivity': otherActivity,
                    });
                  } else {
                    widget.callback(selectedModel, otherActivity);
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
                          color: mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [greenGradientTop, greenGradientBottom])),
                      child: Center(
                          child: Text('Tiếp tục',
                              style: TextStyle(
                                  color: Colors.white,
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

  Widget _buildItem(int index) {
    final widthItem1 = (MediaQuery.of(context).size.width - 64) / 3;
    final widthItem2 = (MediaQuery.of(context).size.width - 48) / 2;
    final ActivityModel activityModel =
        model.length == index ? null : model[index];
    final selectedIndex = activityModel == null
        ? -1
        : selectedModel
            .lastIndexWhere((element) => element.id == activityModel.id);
    return GestureDetector(
      onTap: () {
        if (activityModel == null) {
          _showDialogMore();
        } else {
          setState(() {
            if (selectedIndex == -1) {
              selectedModel.add(activityModel);
            } else {
              selectedModel.removeAt(selectedIndex);
            }
          });
        }
      },
      child: Container(
          width:
              activityModel == null || activityModel.name.split(' ').length < 3
                  ? widthItem1
                  : widthItem2,
          height: 92,
          padding: EdgeInsets.only(left: 8, right: 8),
          decoration: BoxDecoration(
            color: selectedIndex != -1 ||
                    (activityModel == null && otherActivity != null)
                ? Color(0xffF4DBBD).withOpacity(0.7)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selectedIndex != -1 ||
                      (activityModel == null && otherActivity != null)
                  ? Color(0xffE5B440)
                  : Color(0xffB1DDDB),
              width: 1.0,
            ),
          ),
          child: activityModel == null
              ? Center(
                  child: Text('Khác',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(activityModel.icon.url ?? '',
                        width: 40, height: 40),
                    SizedBox(height: 8),
                    Text(activityModel.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                  ],
                )),
    );
  }

  deleteData() async {
    setState(() {
      selectedModel = [];
    });
  }

  _showDialogMore() {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = otherActivity ?? '';
    showDialog(
      context: context,
      // ignore: deprecated_member_use
      builder: (context) {
        return Container(
          child: AlertDialog(
              content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Nhập hoạt động khác',
                    style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                    child: Icon(Icons.close, color: Color(0xffBEC0C8)),
                    onTap: () {
                      Navigator.pop(context);
                    })
              ]),
              SizedBox(height: 16),
              Container(
                  width: width - 137,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 0.5, color: Color(0xff008479))),
                  child: TextField(
                      controller: textEditingController,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                      obscureText: false,
                      decoration: InputDecoration(
                        fillColor: textDark,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xffDDDDDD), width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: mainColor, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Nhập hoạt động của bạn',
                      ),
                      onChanged: (value) {})),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  color: grayBorder),
                              child: Center(
                                child: Text('Huỷ',
                                    style: TextStyle(
                                        color: textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              )),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final otherText = textEditingController.text ?? '';
                            setState(() {
                              otherActivity =
                                  otherText.isEmpty ? null : otherText;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                                color: red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      greenGradientTop,
                                      greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text('Lưu',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          )),
        );
      },
    );
  }
}

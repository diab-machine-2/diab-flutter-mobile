import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/modal/emotion/symptom_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';

typedef SympoCallback = Function(List<SymptomModel>, String);

class AddSymboController extends StatefulWidget {
  final String type;
  final EmotionModel emotion;
  final List<SymptomModel> symptoms;
  final String otherSymptom;
  final SympoCallback callback;

  AddSymboController(
      {this.type,
      this.emotion,
      this.symptoms,
      this.otherSymptom,
      this.callback});
  @override
  _AddSymboControllerState createState() => _AddSymboControllerState();
}

class _AddSymboControllerState extends BaseState<AddSymboController> {
  bool isClicked = false;
  List<SymptomModel> model = [];
  List<SymptomModel> selectedModel = [];
  String otherSymptom;

  ShortGuiModel des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      selectedModel = widget.symptoms;
      otherSymptom = widget.otherSymptom;
    }
    loadData();
    loadDescription();
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    BotToast.showLoading();
    model = await EmotionClient().fetchSymptom();
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
        backgroundColor:  R.color.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.background_splash),
                  fit: BoxFit.cover)),
          child: Column(
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
                            'Bạn có triệu chứng gì\nđặc biệt?',
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 24,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                              'Nhấn \'Tiếp tục\' nếu bạn không có triệu chứng nào',
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ),
                        GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.only(
                                left: 16, right: 16, bottom: 16, top: 46),
                            itemCount: model.length + 1,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 1.2),
                            itemBuilder: (BuildContext context, int index) {
                              return _buildItem(index);
                            }),
                      ],
                    )),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (widget.type == 'input') {
                    Navigator.pushNamed(context, NavigatorName.add_work, arguments: {
                      'type': 'input',
                      'emotion': widget.emotion,
                      'symptoms': selectedModel,
                      'otherSymptom': otherSymptom,
                    });
                  } else {
                    widget.callback(selectedModel, otherSymptom);
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

  deleteData() async {
    setState(() {
      selectedModel = [];
    });
  }

  Widget _buildItem(int index) {
    final SymptomModel symptomModel =
        model.length == index ? null : model[index];
    final selectedIndex = symptomModel == null
        ? -1
        : selectedModel
            .lastIndexWhere((element) => element.id == symptomModel.id);
    return GestureDetector(
      onTap: () {
        if (symptomModel == null) {
          _showDialogMore();
          // if (otherSymptom == null) {

          // } else {
          //   setState(() {
          //     otherSymptom = null;
          //   });
          // }
        } else {
          setState(() {
            if (selectedIndex == -1) {
              selectedModel.add(symptomModel);
            } else {
              selectedModel.removeAt(selectedIndex);
            }
          });
        }
      },
      child: Container(
          decoration: BoxDecoration(
            color: selectedIndex != -1 ||
                    (symptomModel == null && otherSymptom != null)
                ? R.color.color0xffF4DBBD.withOpacity(0.7)
                : R.color.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selectedIndex != -1 ||
                      (symptomModel == null && otherSymptom != null)
                  ? R.color.color0xffE5B440
                  : R.color.color0xffB1DDDB,
              width: 1.0,
            ),
          ),
          padding: EdgeInsets.all(8),
          child: symptomModel == null
              ? Center(
                  child: Text('Khác',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(symptomModel.icon.url ?? '',
                        width: 40, height: 40),
                    SizedBox(height: 8),
                    Text(symptomModel.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400))
                  ],
                )),
    );
  }

  _showDialogMore() {
    final width = MediaQuery.of(context).size.width;
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = otherSymptom ?? '';
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
                Text('Nhập triệu chứng khác',
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                GestureDetector(
                    child: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                    onTap: () {
                      Navigator.pop(context);
                    })
              ]),
              SizedBox(height: 16),
              Container(
                  //height: 127,
                  width: width - 137,
                  child: TextField(
                      controller: textEditingController,
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                      obscureText: false,
                      decoration: InputDecoration(
                        fillColor: R.color.textDark,
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: R.color.grayComponentBorder, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: R.color.mainColor, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Nhập triệu chứng của bạn',
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
                                  color: R.color.grayBorder),
                              child: Center(
                                child: Text('Huỷ',
                                    style: TextStyle(
                                        color: R.color.textDark,
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
                              otherSymptom =
                                  otherText.isEmpty ? null : otherText;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                                color:R.color.red,
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])),
                            child: Center(
                              child: Text('Lưu',
                                  style: TextStyle(
                                      color: R.color.white,
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

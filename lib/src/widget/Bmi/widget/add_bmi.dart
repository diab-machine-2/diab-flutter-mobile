import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/bmi/weight_input.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_date_picker.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';

class AddBmiController extends StatefulWidget {
  final String type;
  final String id;

  AddBmiController({this.type, this.id});
  @override
  _AddBmiControllerState createState() => _AddBmiControllerState();
}

class _AddBmiControllerState extends BaseState<AddBmiController> {
  TextEditingController _controllerWeight = TextEditingController();
  TextEditingController _controllerHeight = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  TextEditingController _controllerHip = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime time = DateTime.now();
  InputWeightModel model;
  TimeFrameModel selectedTimeFrame;
  List<String> removeIDs = [];
  String textValidate = '';
  int selectedWeight = 0;
  int selectedHeight = 0;
  int selectedHip = 0;
  double bmiNumber = 0;

  ShortGuiModel des;

  void initState() {
    print(AppSettings.userInfo);
    if (AppSettings.userInfo.height != 0 &&
        AppSettings.userInfo.height != null) {
      selectedHeight = AppSettings.userInfo.height.toInt();
    }
    super.initState();
    if (widget.type == 'update' && widget.id != null) {
      loadDataDetail();
    } else {
      loadTimeFrame();
    }
    loadDescription();
    TrackingManager.analytics.setCurrentScreen(screenName: 'BMI Input');
  }

  void dispose() {
    super.dispose();
  }

  loadDataDetail() async {
    BotToast.showLoading();
    model = await WeightClient().fetchDetail(widget.id);
    BotToast.closeAllLoading();
    bmiNumber = model.bmi;
    selectedWeight = model.weight == null ? 0 : model.weight.toInt();
    selectedHeight = model.height == null ? 0 : model.height.toInt();
    _controllerNote.text = model.note;
    selectedHip = model.waist == null ? 0 : model.waist.toInt();
    files.addAll(model.images);
    selectedDate = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
    selectedTimeFrame = TimeFrameModel(
        id: model.timeFrameId, code: '', name: model.timeFrameText);
    setState(() {});
  }

  loadTimeFrame() async {
    BotToast.showLoading();
    final timeFrames = await GlucoseClient().fetchFlucoseTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(7);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          _showDialogSave();
          return false;
        },
        child: Scaffold(
          backgroundColor:  R.color.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(
                      widget.type == 'update'
                          ? 'Cập nhật chỉ số cân nặng'
                          : 'Nhập chỉ số cân nặng',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark)),
                  leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.textDark),
                      onPressed: () {
                        _showDialogSave();
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
                            ? Image.asset(
                                R.drawable.help_circle_active,
                                width: 24,
                                height: 24)
                            : Image.asset(R.drawable.help_circle,
                                width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(0),
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: isClicked
                                ? Description(
                                    input: true,
                                    data: des,
                                    titleDetail:
                                        'Kiểm soát cân nặng bệnh tiểu đường')
                                : SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: R.color.color0xffB1DDDB),
                            padding: EdgeInsets.only(right: 20),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 16, right: 32, top: 9),
                                  child: Image.asset(
                                      R.drawable.male_weight,
                                      height: 131),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Chỉ số BMI của bạn:',
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500)),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(roundNumber(bmiNumber),
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700)),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.0, left: 4),
                                            child: Text(
                                              'kg/m²',
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // color: R.color.white,
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Image.asset(R.drawable.scale,
                                            width: 22, height: 22),
                                        SizedBox(width: 8),
                                        Text('Cân nặng & chiều cao',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        // SizedBox(height: 16),
                                      ]),
                                      SizedBox(height: 16),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          barrierColor: R.color.color0xff003F38
                                                              .withOpacity(0.5),
                                                          context: context,
                                                          builder: (_) =>
                                                              CustomNumPicker(
                                                                  callback:
                                                                      (number) {
                                                                    setState(
                                                                        () {
                                                                      selectedWeight =
                                                                          number;
                                                                    });
                                                                    handleBMI();
                                                                  },
                                                                  title:
                                                                      'Nhập cân nặng',
                                                                  max: 180,
                                                                  numberDefault:
                                                                      selectedWeight ==
                                                                              0
                                                                          ? 50
                                                                          : selectedWeight,
                                                                  unit: 'kg'),
                                                        );
                                                      },
                                                      child: Container(
                                                          width: 80,
                                                          child: Center(
                                                            child: Text(
                                                                selectedWeight ==
                                                                        0
                                                                    ? '-'
                                                                    : selectedWeight
                                                                        .toString(),
                                                                style: TextStyle(
                                                                    color: selectedWeight ==
                                                                            0
                                                                        ? R.color.captionColorGray
                                                                        : R.color.textDark,
                                                                    fontSize:
                                                                        34,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500)),
                                                          )),
                                                    ),
                                                    Container(
                                                        height: 1,
                                                        width: 54,
                                                        color:
                                                            R.color.color0xffE5E5E5)
                                                  ],
                                                ),
                                                Text('kg',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                SizedBox(
                                                  width: 16,
                                                )
                                              ],
                                            ),
                                            (AppSettings.userInfo.height == 0 ||
                                                    AppSettings
                                                            .userInfo.height ==
                                                        null)
                                                ? Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 8.0),
                                                        child: Text('/',
                                                            style: TextStyle(
                                                              fontSize: 30,
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: 16,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    showDialog(
                                                                      barrierColor: R.color.color0xff003F38
                                                                          .withOpacity(
                                                                              0.5),
                                                                      context:
                                                                          context,
                                                                      builder: (_) => CustomNumPicker(
                                                                          callback: (num) {
                                                                            print(num);
                                                                            setState(() {
                                                                              selectedHeight = num;
                                                                            });
                                                                            handleBMI();
                                                                          },
                                                                          title: 'Nhập chiều cao',
                                                                          max: 250,
                                                                          numberDefault: selectedHeight == 0 ? 150 : selectedHeight,
                                                                          unit: 'cm'),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 80,
                                                                    child:
                                                                        Center(
                                                                      child: Text(
                                                                          selectedHeight == 0
                                                                              ? '-'
                                                                              : selectedHeight
                                                                                  .toString(),
                                                                          style: TextStyle(
                                                                              color: selectedHeight == 0 ? R.color.captionColorGray : R.color.textDark,
                                                                              fontSize: 34,
                                                                              fontWeight: FontWeight.w500)),
                                                                    ),
                                                                  )),
                                                              Container(
                                                                  height: 1,
                                                                  width: 54,
                                                                  color: R.color.color0xffE5E5E5)
                                                            ],
                                                          ),
                                                          Text('cm',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                              )),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                      textValidate.isNotEmpty
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(textValidate,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:R.color.red,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            )
                                          : SizedBox(),
                                    ]),
                                SizedBox(height: 20),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Image.asset(R.drawable.ruler,
                                            width: 22, height: 22),
                                        SizedBox(width: 8),
                                        Text('Vòng eo',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        // SizedBox(height: 16),
                                      ]),
                                      SizedBox(height: 8),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          barrierColor: R.color.color0xff003F38
                                                              .withOpacity(0.5),
                                                          context: context,
                                                          builder: (_) =>
                                                              CustomNumPicker(
                                                                  callback:
                                                                      (num) {
                                                                    print(num);
                                                                    setState(
                                                                        () {
                                                                      selectedHip =
                                                                          num;
                                                                    });
                                                                  },
                                                                  title:
                                                                      'Nhập vòng eo',
                                                                  max: 180,
                                                                  numberDefault:
                                                                      selectedHip ==
                                                                              0
                                                                          ? 60
                                                                          : selectedHip,
                                                                  unit: 'cm'),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: 80,
                                                        child: Center(
                                                          child: Text(
                                                              selectedHip == 0
                                                                  ? '-'
                                                                  : selectedHip
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  color: selectedHip ==
                                                                          0
                                                                      ? R.color.captionColorGray
                                                                      : R.color.textDark,
                                                                  fontSize: 34,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                        height: 1,
                                                        width: 54,
                                                        color:
                                                            R.color.color0xffE5E5E5)
                                                  ],
                                                ),
                                                Text('cm',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      textValidate.isNotEmpty
                                          ? Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(textValidate,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:R.color.red,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            )
                                          : SizedBox(),
                                    ]),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor:
                                        R.color.color0xff003F38.withOpacity(0.5),
                                    context: context,
                                    builder: (_) => DateMultiPicker(
                                      initDate: selectedDate,
                                      callback: (date) {
                                        setState(() {
                                          selectedDate = date;
                                        });
                                        loadTimeFrame();
                                      },
                                      // selectedHour: (hour) {
                                      //   setState(() {
                                      //     selectedHour = hour;
                                      //   });
                                      // },
                                      // selectedMinute: (minute) {
                                      //   setState(() {
                                      //     selectedMinute = minute;
                                      //   });
                                      // },
                                    ),
                                  );
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                              R.drawable.icon_calendar,
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 8),
                                          Row(
                                            children: [
                                              Text(
                                                  convertToUTC(
                                                      selectedDate
                                                              .millisecondsSinceEpoch ~/
                                                          1000,
                                                      'HH:mm - dd/MM/yyyy'),
                                                  style: TextStyle(
                                                      color: R.color.textDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          )
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: R.color.color0xffE5E5E5),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showActionFilter(context);
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                              R.drawable.icon_clock,
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 8),
                                          Text(
                                              selectedTimeFrame == null
                                                  ? 'Chọn khung giờ'
                                                  : selectedTimeFrame.name,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: R.color.color0xffE5E5E5),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // color: R.color.white,
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.note_text,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text('Ghi chú',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                  ]),
                                  SizedBox(height: 24),
                                  TextField(
                                      controller: _controllerNote,
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: 'Nhập ghi chú của bạn',
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: R.color.primaryGreyColor))),
                                  Container(
                                      height: 1, color: R.color.color0xffE5E5E5),
                                  SizedBox(height: 8),
                                  GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: files.length + 1,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              if (index == files.length) {
                                                showActionSheet(context);
                                              }
                                            },
                                            child: index == files.length
                                                ? Container(
                                                    child: Image.asset(
                                                        R.drawable.icon_add_photo))
                                                : Stack(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .topEnd,
                                                    children: [
                                                        Positioned.fill(
                                                          child: files[index]
                                                                  is PickedFile
                                                              ? Image.file(
                                                                  File(files[
                                                                          index]
                                                                      .path),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.network(
                                                                  files[index]
                                                                      .url,
                                                                  fit: BoxFit
                                                                      .cover),
                                                        ),
                                                        IconButton(
                                                            icon: Image.asset(
                                                                R.drawable.icon_trash),
                                                            onPressed: () {
                                                              setState(() {
                                                                if (files[index]
                                                                    is PickedFile) {
                                                                  files.removeAt(
                                                                      index);
                                                                } else {
                                                                  removeIDs.add(
                                                                      files[index]
                                                                          .id);
                                                                  files.removeAt(
                                                                      index);
                                                                }
                                                              });
                                                            })
                                                      ]));
                                      })
                                ]),
                          ),
                        ),
                      ]),
                ),
                widget.type == 'input'
                    ? GestureDetector(
                        onTap: () async {
                          _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                              margin: EdgeInsets.only(top: 16, bottom: 16),
                              height: 48,
                              width: 195,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
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
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)))),
                        ),
                      )
                    : SafeArea(
                        top: false,
                        child: Container(
                            margin: EdgeInsets.all(16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDialogDelete(context);
                                    },
                                    child: Container(
                                        height: 48,
                                        width: 164,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            border: Border.all(
                                                color:R.color.red, width: 2)),
                                        child: Center(
                                          child: Text('Xoá dữ liệu',
                                              style: TextStyle(
                                                  color: R.color.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      editData();
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: R.color.mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
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
                                ])),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await WeightClient().deleteIndexBmi(widget.id);
      if (result == true) {
        Message.showToastMessage(context, 'Xoá thành công');
        DartNotificationCenter.post(channel: 'Weight_change_data');
        Navigator.pop(context);
      }
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

  editData() async {
    final weight = _controllerWeight.text ?? '';
    final height = _controllerHeight.text ?? '';
    final hip = _controllerHip.text ?? '';
    final note = _controllerNote.text ?? '';

    // if (weight.isEmpty) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập chỉ số cân nặng');
    //   return;
    // }
    // if (height.isEmpty) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập chỉ số chiều cao');
    //   return;
    // }
    // if (hip.isEmpty) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập chỉ số vòng eo');
    //   return;
    // }
    // if (selectedDate == null) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
    //   return;
    // }
    // if (selectedTimeFrame == null) {
    //   Message.showToastMessage(context, 'Bạn chưa chọn khung giờ');
    //   return;
    // }
    // if (note == null) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập lý do');
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await WeightClient().putIndexBmi(
          widget.id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedWeight.toString(),
          selectedHip.toString(),
          selectedHeight.toString(),
          note,
          selectedTimeFrame.id,
          removeIDs,
          paths);
      if (result == true) {
        updateHeightProfile();
        Message.showToastMessage(context, 'Lưu thành công');
        DartNotificationCenter.post(channel: 'Weight_change_data');
        Navigator.pop(context);
      }

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

  _submitData() async {
    final note = _controllerNote.text ?? '';

    if (selectedWeight == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập chỉ số cân nặng');
      return;
    }
    if (selectedHeight == 0) {
      Message.showToastMessage(context, 'Bạn chưa nhập chỉ số chiều cao');
      return;
    }
    // if (selectedHip == 0) {
    //   Message.showToastMessage(context, 'Bạn chưa nhập chỉ số vòng eo');
    //   return;
    // }
    if (selectedDate == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn khung giờ');
      return;
    }
    if (note == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập ghi chú');
      return;
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await WeightClient().postWeightInput(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          paths,
          selectedWeight.toString(),
          selectedHip == 0 ? null : selectedHip.toString(),
          selectedHeight.toString(),
          note,
          selectedTimeFrame.id);
      BotToast.closeAllLoading();
      if (result == true) {
        updateHeightProfile();
        DartNotificationCenter.post(channel: 'Weight_change_data');
        Navigator.pop(context);
      }
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  updateHeightProfile() async {
    UserModel userInfo = AppSettings.userInfo;
    userInfo = UserModel(
        id: userInfo.id,
        username: userInfo.username,
        fullName: userInfo.fullName,
        age: userInfo.age,
        phoneNumber: userInfo.phoneNumber,
        secondPhoneNumber: userInfo.secondPhoneNumber,
        gender: userInfo.gender,
        genderType: userInfo.genderType,
        createDatetime: userInfo.createDatetime,
        isActive: userInfo.isActive,
        province: userInfo.province,
        district: userInfo.district,
        height: selectedHeight * 1.0,
        weight: selectedWeight * 1.0,
        ward: userInfo.ward,
        dateOfBirth: userInfo.dateOfBirth,
        diabetesStatus: userInfo.diabetesStatus,
        diabetesName: userInfo.diabetesName,
        diabetesDate: userInfo.diabetesDate,
        imageUrl: userInfo.imageUrl,
        code: userInfo.code,
        email: userInfo.email,
        address: userInfo.address,
        goalWaist: userInfo.goalWaist,
        goalWeight: userInfo.goalWeight,
        isLinkedFacebook: userInfo.isLinkedFacebook,
        isLinkedGoogle: userInfo.isLinkedGoogle,
        isMobileAccount: userInfo.isMobileAccount,
        glucoseUnit: userInfo.glucoseUnit,
        firstLinkedAccount: userInfo.firstLinkedAccount);
    try {
      BotToast.showLoading();
      await UserClient().updateUserInfo(AppSettings.userInfo.id, userInfo);
      await UserClient().fetchUser();
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

  _showDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.earseIcon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn xoá dữ liệu?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Các thống kê sẽ thay đổi khi dữ liệu bị xoá, bạn vẫn chắc chắn muốn xoá?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
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
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Quay lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    deleteData();
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color:R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Center(
                                      child: Text('Xoá',
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
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  _showDialogSave() {
    final note = _controllerNote.text ?? '';
    if (model != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
      if (selectedWeight == 0 &&
          selectedHeight == 0 &&
          selectedHip == 0 &&
          note.isEmpty &&
          files.length == model.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else if (selectedWeight == 0 &&
        selectedHip == 0 &&
        note.isEmpty &&
        note.isEmpty &&
        files.length == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_back_icon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn quay lại ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Dữ liệu đang nhập sẽ không được lưu lại, bạn vẫn chắc chắn muốn thoát?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Vẫn ở lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color:R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Thoát',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => ActionListTrend(
            selected: selectedTimeFrame,
            callback: (value) {
              print(value);
              setState(() {
                selectedTimeFrame = value;
              });
            }));
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (files.length < maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.icon_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chọn trong thư viện",
                      style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(context);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.icon_photo,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chụp ảnh",
                      style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(context);
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Huỷ",
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      Message.showToastMessage(context, 'Chỉ đuợc chọn tối đa 5 ảnh');
    }
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Huỷ"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Cấp quyền"),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Thông báo"),
      content: Text("Bạn cần cấp quyền truy cập để sử dụng tính năng này"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  handleBMI() async {
    BotToast.showLoading();
    if (selectedWeight != 0 && selectedHeight != 0) {
      final result =
          await WeightClient().fetchCaculateBMI(selectedWeight, selectedHeight);
      bmiNumber = result.bmi;
    }
    BotToast.closeAllLoading();

    setState(() {});
  }
}

typedef TimeCallback = Function(DateTime);

class DateMultiPicker extends StatefulWidget {
  final DateTime initDate;
  final TimeCallback callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate.hour;
      selectedMinute = widget.initDate.minute;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Chọn ngày',
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon:
                                    Icon(Icons.close, color: R.color.color0xffBEC0C8),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null
                            ? DateTime.now()
                            : widget.initDate,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime datetime) {
                          selectedDate = datetime;
                        }),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text('Chọn thời gian',
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTimePicker(
                        selectedHour: selectedHour,
                        selectedMinute: selectedMinute,
                        callback: (hour, minute) {
                          selectedHour = hour;
                          selectedMinute = minute;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.grayBorder,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text('Huỷ',
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedHour,
                                selectedMinute);

                            widget.callback(selectedDate);

                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text('Đồng ý',
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                    ]),
                    SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef TimeHourCallback = Function(int, int);

class CustomTimePicker extends StatefulWidget {
  final int selectedHour;
  final int selectedMinute;
  final TimeHourCallback callback;
  CustomTimePicker({this.selectedHour, this.selectedMinute, this.callback});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;
  int selectedHour = 1;
  int selectedMinute = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedHour = now.hour;
    selectedMinute = now.minute;
    if (widget.selectedHour != null) {
      selectedHour = widget.selectedHour;
    }
    if (widget.selectedMinute != null) {
      selectedMinute = widget.selectedMinute;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 150,
            width: 106,
            child: CupertinoPicker(
                scrollController: hourController,
                selectionOverlay: null,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedHour = value;
                    widget.callback(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(24, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedHour == e
                                      ? R.color.mainColor
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList())),
        SizedBox(width: 24),
        Container(
            height: 150,
            width: 106,
            child: CupertinoPicker(
                scrollController: minuteController,
                selectionOverlay: null,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedMinute = value;
                    widget.callback(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(60, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedMinute == e
                                      ? R.color.mainColor
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList()))
      ],
    );
  }
}

String formatDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);

  return 'Tháng ${date.month}, ${date.year}';
}

typedef NumCallback = Function(int);

class CustomNumPicker extends StatefulWidget {
  final NumCallback callback;
  final String title;
  final String subTitle;
  final int max;
  final int numberDefault;
  final String unit;
  CustomNumPicker(
      {this.callback,
      this.title,
      this.subTitle,
      this.max,
      this.numberDefault,
      this.unit});
  @override
  CustomNumPickerState createState() => CustomNumPickerState();
}

class CustomNumPickerState extends State<CustomNumPicker> {
  FixedExtentScrollController numController;
  int selectedNum;
  @override
  void initState() {
    selectedNum = widget.numberDefault;
    super.initState();
    numController = FixedExtentScrollController(initialItem: selectedNum);
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
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.title.toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                widget.subTitle == null
                                    ? SizedBox()
                                    : Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, right: 8),
                                        child: Text(widget.subTitle,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      )
                              ]),
                        ),
                        IconButton(
                            // padding: EdgeInsets.only(right: 30),
                            icon: Icon(Icons.close, color: R.color.grey),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 150,
                          width: 106,
                          child: CupertinoPicker(
                              scrollController: numController,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedNum = value;
                                });
                              },
                              itemExtent: 47.0,
                              children:
                                  List<int>.generate(widget.max + 1, (i) => i)
                                      .map((e) => Center(
                                            child: Text('$e',
                                                style: TextStyle(
                                                    color: selectedNum == e
                                                        ? R.color.mainColor
                                                        : R.color.color0xffC0C2C5,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))
                                      .toList())),
                      SizedBox(width: 8),
                      Text(widget.unit)
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                width: 150,
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
                          GestureDetector(
                            onTap: () {
                              widget.callback(selectedNum);
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
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ]),
                                borderRadius: BorderRadius.circular(200),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

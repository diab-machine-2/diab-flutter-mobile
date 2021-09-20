import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/modal/exercrises/exercrises_active.dart';
import 'package:medical/src/modal/exercrises/exercrises_categogy_request.dart';
import 'package:medical/src/modal/exercrises/exercrises_intensity.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Exercrises/widget/action_list_active.dart';
import 'package:medical/src/widget/Exercrises/widget/action_list_intensity.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

typedef DataCallback = Function(ExercrisesCategoryModel);

class InputDetailExercrisesController extends StatefulWidget {
  final ExercrisesCategoryModel model;
  final DataCallback datacallback;
  InputDetailExercrisesController({this.model, this.datacallback});

  @override
  _InputDetailExercrisesControllerState createState() =>
      _InputDetailExercrisesControllerState();
}

class _InputDetailExercrisesControllerState
    extends BaseState<InputDetailExercrisesController> {
  ExercriseIntensityModel selectedintensity;
  ExercriseActiveModel selectedActive;
  int selectedHour = 0;
  int selectedMinute = 0;
  String textValidate = '';
  double calorisesNumber = 0.0;
  String unit = '';
  String description = '';

  void initState() {
    super.initState();
    loadData();
  }

  void dispose() {
    super.dispose();
  }

  loadData() async {
    BotToast.showLoading();
    final intensity =
        await ExercrisesClient().fetchIntensity(widget.model.categoryId);
    BotToast.closeAllLoading();
    if (widget.model.exerciseIntensityId == null) {
      selectedintensity = intensity.length > 0 ? intensity.first : null;
    } else {
      selectedintensity = intensity.lastWhere(
          (element) => element.id == widget.model.exerciseIntensityId,
          orElse: () => intensity.first);
    }

    loadActive();
  }

  loadActive() async {
    BotToast.showLoading();
    final active = await ExercrisesClient()
        .fetchActive(widget.model.categoryId, selectedintensity.id);
    BotToast.closeAllLoading();

    if (widget.model.exerciseId == null) {
      selectedActive = active.length > 0 ? active.first : null;
    } else {
      selectedActive = active.lastWhere(
          (element) => element.id == widget.model.exerciseId,
          orElse: () => active.first);
      selectedHour = (widget.model.duration / 60).floor();
      selectedMinute = widget.model.duration.toInt() - (selectedHour * 60);
    }

    if (selectedHour != 0 || selectedMinute != 0) {
      handleCaculate(widget.model.categoryId, selectedintensity.id,
          selectedActive.id, selectedMinute, selectedHour);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.bg_splash),
                  fit: BoxFit.cover)),
          child: Column(
            children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text(widget.model.category,
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
                actions: [],
              ),
              Expanded(
                child: ListView(padding: EdgeInsets.all(0),
                    // physics: NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 16, left: 16, right: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image:
                                    AssetImage(R.drawable.bg_sub_exe),
                                fit: BoxFit.cover,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: Column(
                              children: [
                                Image.network(widget.model.cover.url ?? '',
                                    width: 50, height: 50),
                                SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(formatNumber(calorisesNumber),
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700)),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2.0, left: 2),
                                      child: Text(
                                        'kcal',
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                    context: context,
                                    builder: (_) => ActionListIntensity(
                                        exercrisesID: widget.model.categoryId,
                                        selected: selectedintensity,
                                        callback: (value) {
                                          selectedintensity = value;
                                          loadActive();
                                        }));
                              },
                              child: Container(
                                color: R.color.transparent,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                            R.drawable.icon_bar_chart,
                                            width: 24,
                                            height: 24),
                                        SizedBox(width: 8),
                                        Text(
                                            selectedintensity == null
                                                ? 'Chọn cường độ hoạt động'
                                                : selectedintensity.name,
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
                          padding: EdgeInsets.all(16),
                          child: Column(children: [
                            GestureDetector(
                              onTap: () {
                                selectedintensity != null
                                    ? showDialog(
                                        context: context,
                                        builder: (_) => ActionListActive(
                                            callback: (value) {
                                              setState(() {
                                                selectedActive = value;
                                              });

                                              if (selectedHour != 0) {
                                                handleCaculate(
                                                    widget.model.categoryId,
                                                    selectedintensity.id,
                                                    selectedActive.id,
                                                    selectedMinute,
                                                    selectedHour);
                                              }
                                            },
                                            exerciseCategoryId:
                                                widget.model.categoryId,
                                            exerciseIntensityId:
                                                selectedintensity.id,
                                            selected: selectedActive,
                                            title: widget.model.category))
                                    : Message.showToastMessage(
                                        context, 'Bạn chưa chọn cường độ');
                              },
                              child: Container(
                                color: R.color.transparent,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            R.drawable.icon_clock,
                                            width: 24,
                                            height: 24),
                                        SizedBox(width: 8),
                                        selectedActive == null
                                            ? Text('Chọn hình thức hoạt động',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400))
                                            : Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(selectedActive.name,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ],
                                                ),
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
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                barrierColor:
                                    R.color.color0xff003F38.withOpacity(0.5),
                                context: context,
                                builder: (_) => CustomInputTimePicker(
                                    time: selectedMinute + selectedHour * 60.0,
                                    callback: (hour, minute) {
                                      // print(hour);
                                      // print(minute);
                                      selectedMinute = minute.toInt();
                                      selectedHour = hour.toInt();
                                      // selectedHour != 0 ??
                                      handleCaculate(
                                          widget.model.categoryId,
                                          selectedintensity.id,
                                          selectedActive.id,
                                          selectedMinute,
                                          selectedHour);
                                    }));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.stopwatch,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text('Thời gian vận động',
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
                                          Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                child: Center(
                                                  child: Text(
                                                      selectedHour.toString(),
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                  height: 1,
                                                  width: 54,
                                                  color: R.color.color0xffE5E5E5)
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text('giờ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                child: Center(
                                                  child: Text(
                                                      selectedMinute.toString(),
                                                      style: TextStyle(
                                                          color: R.color.textDark,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Container(
                                                  height: 1,
                                                  width: 54,
                                                  color: R.color.color0xffE5E5E5)
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8),
                                            child: Text('phút',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                          ),
                                        ]),
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
                                                    color: R.color.red,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ],
                                        )
                                      : SizedBox(),
                                ]),
                          ),
                        ),
                      ),
                    ]),
              ),
              GestureDetector(
                onTap: () async {
                  submit();
                },
                child: Container(
                    margin: EdgeInsets.only(bottom: 32),
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
                        child: Text('Lưu',
                            style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16)))),
              )
            ],
          ),
        ),
      ),
    );
  }

  handleIntensity(String intensityId) {
    if (selectedActive.id == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn hình thức');
      return;
    }
    handleCaculate(widget.model.categoryId, intensityId, selectedActive.id,
        selectedMinute, selectedHour);
  }

  handleCaculate(String categoryId, String intensityId, String activeId,
      int selectedMinute, int selectedHour) async {
    if (intensityId == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn hình thức');
      return;
    }
    if (activeId == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn hình thức');
      return;
    }
    if (categoryId.isNotEmpty &&
        activeId.isNotEmpty &&
        selectedHour != null &&
        selectedMinute != null) {
      final duration = selectedHour * 60 + selectedMinute;
      BotToast.showLoading();
      final response = await ExercrisesClient()
          .fetchCalories(categoryId, intensityId, activeId, duration);
      BotToast.closeAllLoading();
      setState(() {
        calorisesNumber = response['calories'];
        unit = response['unit'];
        description = response['description'];
      });
      print(calorisesNumber);
    }
  }

  submit() {
    if (selectedintensity == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn cường độ');
      return;
    } else if (selectedActive == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn hình thức');
      return;
    } else if (selectedHour == 0 && selectedMinute == 0) {
      Message.showToastMessage(context, 'Bạn chưa chọn thời gian');
      return;
      // }
      // else if (calorisesNumber == 0) {
      //   Message.showToastMessage(context, 'Tính lượng calories chưa hoàn tất!');
      //   return;
    }
    if (description.isNotEmpty) {
      showDialog(
          barrierColor: R.color.color0xff003F38.withOpacity(0.5),
          context: context,
          builder: (_) {
            Future.delayed(const Duration(seconds: 5), () {
              Navigator.pop(context);
              callbackData();
            });
            return Scaffold(
                backgroundColor: R.color.transparent,
                body: Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.only(top: 32, left: 32, right: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Chúc mừng!',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 16),
                          Text(
                              'Tuyệt vời! Bạn đã phá kỷ lục thời gian tập luyện. Kỷ lục hiện tại của bạn với bộ môn này là:',
                              textAlign: TextAlign.center),
                          SizedBox(height: 8),
                          Text(
                              (selectedHour * 60 + selectedMinute)
                                      .toDouble()
                                      .round()
                                      .toString() +
                                  ' phút',
                              style: TextStyle(
                                  color: R.color.mainColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          Image.asset(R.drawable.im_congrat),
                        ],
                      )),
                )));
          });
    } else {
      callbackData();
    }
  }

  callbackData() {
    final modelCallback = ExercrisesCategoryModel(
        categoryId: widget.model.categoryId,
        category: widget.model.category,
        exerciseId: selectedActive.id,
        code: widget.model.code,
        duration: (selectedHour * 60 + selectedMinute).toDouble(),
        burnedCalorie: calorisesNumber,
        exerciseIntensityId: selectedintensity.id,
        unit: unit,
        description: selectedActive.intensityName,
        order: widget.model.order,
        cover: widget.model.cover);
    widget.datacallback(modelCallback);
    Navigator.pop(context);
  }
}

typedef TimeHourCallback = Function(int, int);

class CustomInputTimePicker extends StatefulWidget {
  final String title;
  final double time;
  final int maxHour;
  final TimeHourCallback callback;
  CustomInputTimePicker(
      {this.maxHour = 10, this.title, this.time, this.callback});
  @override
  _CustomInputTimePickerState createState() => _CustomInputTimePickerState();
}

class _CustomInputTimePickerState extends State<CustomInputTimePicker> {
  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;
  int selectedHour = 0;
  int selectedMinute = 0;

  @override
  void initState() {
    super.initState();
    if (widget.time != null) {
      selectedHour = (widget.time / 60).floor();
      selectedMinute = widget.time.toInt() - (selectedHour * 60);
      selectedMinute =
          (((selectedMinute / 10 * 2).ceil() / 2) * 10 ~/ 5).toInt();
      hourController = FixedExtentScrollController(initialItem: selectedHour);
      minuteController =
          FixedExtentScrollController(initialItem: selectedMinute);
    }
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
                        Text(
                            widget.title == null
                                ? 'Nhập thời gian'
                                : widget.title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
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
                              scrollController: hourController,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedHour = value;
                                });
                              },
                              itemExtent: 47.0,
                              children:
                                  List<int>.generate(widget.maxHour, (i) => i)
                                      .map((e) => Center(
                                            child: Text(
                                                // e.toString().length == 1
                                                //     ? '0$e'
                                                // :
                                                '$e',
                                                style: TextStyle(
                                                    color: selectedHour == e
                                                        ? R.color.mainColor
                                                        : R.color.color0xffC0C2C5,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ))
                                      .toList())),
                      Text('Giờ',
                          style: TextStyle(fontWeight: FontWeight.w500)),
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
                                  // widget.callback(selectedHour, selectedMinute);
                                });
                              },
                              itemExtent: 47.0,
                              children: List<int>.generate(12, (i) => i)
                                  .map((e) => Center(
                                        child: Text(
                                            // e.toString().length == 1
                                            //     ? '0$e'
                                            //     :
                                            '${e * 5}',
                                            style: TextStyle(
                                                color: selectedMinute == e
                                                    ? R.color.mainColor
                                                    : R.color.color0xffC0C2C5,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                  .toList())),
                      Text('Phút',
                          style: TextStyle(fontWeight: FontWeight.w500)),
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
                              if (selectedHour == 0 && selectedMinute == 0) {
                                Message.showToastMessage(
                                    context, 'Bạn chưa nhập thời gian');
                                return;
                              }
                              widget.callback(selectedHour, selectedMinute * 5);
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
                                child: Text(
                                    widget.title == null
                                        ? 'Tiếp tục'
                                        : 'Đồng ý',
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

String formatDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);

  return 'Tháng ${date.month}, ${date.year}';
}

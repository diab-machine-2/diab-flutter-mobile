import 'dart:developer' as developer;
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

import 'food_detail_tabbar.dart';
import 'search_food_controller.dart';

class ConfirmGeneratedFood extends StatefulWidget {
  final List<FoodModel> generatedFoods;
  final String timeframe;
  final String timeframeId;
  final List<String> files;

  const ConfirmGeneratedFood({
    Key? key,
    required this.generatedFoods,
    required this.timeframe,
    required this.timeframeId,
    required this.files,
  }) : super(key: key);

  @override
  _ConfirmGeneratedFoodState createState() => _ConfirmGeneratedFoodState();
}

class _ConfirmGeneratedFoodState extends State<ConfirmGeneratedFood> {
  final TextEditingController _controllerNote = TextEditingController();
  final List<FoodModel> _selectedFoods = [];
  List<dynamic> files = [];
  int maxMedia = 5;
  DateTime selectedDate = DateTime.now();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();
  final List<dynamic> _files = [];

  bool get _haveFood => _selectedFoods.isNotEmpty;

  double get totalKcal => _selectedFoods.fold(
      0,
      (sum, food) =>
          sum + (food.calorie ?? 0) * (food.portion?.toDouble() ?? 0));

  @override
  void initState() {
    super.initState();
    _selectedFoods.addAll(widget.generatedFoods);
    _files.addAll(widget.files.map((e) => File(e)).toList());
    try {
      developer.log(
          '[CAPTURE] Confirm page received files count: ' +
              widget.files.length.toString() +
              ', paths: ' +
              widget.files.join(', '),
          name: '[CAPTURE]');
    } catch (_) {}
  }

  @override
  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }

  void _onTapDateTime() async {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => DateMultiPicker(
        initDate: selectedDate,
        callback: (date) {
          setState(() {
            selectedDate = date ?? DateTime.now();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: R.color.glucose_bg_color,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              _appBarSection(),
              Expanded(
                child: Stack(
                  children: [
                    // Scrollable content
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Background image section
                                Container(
                                  height: 298,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: widget.files.length > 0
                                            ? Image.file(
                                                File(widget.files.first),
                                                fit: BoxFit.cover,
                                              )
                                            : SizedBox(),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Sticky date time picker overlay
                                      Positioned(
                                        top: 16,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                            child: _dateTimePickerOverlay()),
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(0, -70),
                                  child: Column(
                                    children: [
                                      _mealSummarySection(),
                                      const SizedBox(height: 16),
                                      _notesSection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildButton(),
                      ],
                    ),
                    // Sticky date time picker overlay
                    // Positioned(
                    //   top: 16,
                    //   left: 0,
                    //   right: 0,
                    //   child: Center(child: _dateTimePickerOverlay()),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        widget.timeframe,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.white,
        highlightColor: R.color.white,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () {
          _showDialogSave();
        },
      ),
      // actions: [
      //   Center(
      //     child: Padding(
      //       padding: const EdgeInsets.only(right: 12.0),
      //       child: InkWell(
      //         onTap: () {
      //           // Show guide or instructions
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      //           child: Text(
      //             R.string.huong_dan.tr(),
      //             style: TextStyle(color: R.color.white, fontSize: 15),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _dateTimePickerOverlay() {
    return GestureDetector(
      onTap: _onTapDateTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: R.color.color0xffDFE4E4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              convertToUTC(
                selectedDate.millisecondsSinceEpoch ~/ 1000,
                'HH:mm - dd/MM/yyyy',
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: R.color.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          // Header with total calories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.bua_an_gom.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    formatNumber(totalKcal),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: R.color.mainColor,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    R.string.kcal.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.captionColorGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Food Items List
          Column(
            children: _selectedFoods
                .asMap()
                .map(
                  (index, food) => MapEntry(
                    index,
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: R.color.color0xffF7F8F8,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '${food.unit ?? ''}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: R.color.color0xff636A6B,
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: R.color.color0xffD6D8E0,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      '${formatNumber((food.calorie ?? 0) * (food.portion ?? 0))} ${R.string.kcal.tr()}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: R.color.color0xff636A6B,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFoods.removeAt(index);
                              });
                            },
                            child: Image.asset(
                              R.drawable.ic_food_delete,
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
          // Add Food Button
          GestureDetector(
            onTap: () {
              _addFood(context);
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: R.color.mainColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: R.color.mainColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    R.string.them_mon_an.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SectionAddNote(
        focusNode: _focusNode,
        controllerNote: _controllerNote,
        maxMedia: 5,
        key: _sectionAddNoteKey,
        initialFiles: _files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 12),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: 44,
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 44,
        maxHeight: 44,
        maxWidth: 351,
      ),
      child: GestureDetector(
        onTap: _haveFood ? _submitData : null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: _haveFood ? Color(0xFF008479) : R.color.grayBorder,
          ),
          child: Center(
            child: Text(
              R.string.confirm.tr(),
              style: TextStyle(
                color: R.color.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addFood(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return SearchFoodController(
            foods: _selectedFoods,
            callback: (foods) {
              setState(() {
                _selectedFoods.clear();
                _selectedFoods.addAll(foods);
              });
            },
          );
        },
      ),
    );
  }

  // Logic lib/src/widget/Food/add_food.dart function [_submitData]
  void _submitData() async {
    BotToast.showLoading();

    try {
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        if (file is String) {
          // If the file is a path, add it directly
          paths.add(file);
        } else {
          // If the file is a File object, convert it to a path
          paths.add(file.path);
        }
      }
      final note = data.note;
      final result = await FoodClient().postIndexFoodAI(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          widget.timeframeId,
          note,
          _selectedFoods,
          paths);
      if (result == true) {
        Observable.instance.notifyObservers([], notifyName: "food_change_data");
        Navigator.pop(context);
        NavigationUtil.navigatePage(context, FoodDetailTabbarController());
      }
      print("[KPI] close all loading.");
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

  void _showDialogSave() {
    final note = _controllerNote.text;

    if (note.isEmpty && _selectedFoods.isEmpty && files.isEmpty) {
      Navigator.pop(context);
      Navigator.pushNamed(context, NavigatorName.food_image_capture,
          arguments: {
            'timeframe': widget.timeframe,
            'timeframeId': widget.timeframeId,
          });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.ban_muon_quay_lai.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.confirm_to_back.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
                                borderRadius: BorderRadius.circular(200),
                                color: R.color.grayBorder,
                              ),
                              child: Center(
                                child: Text(
                                  R.string.van_o_lai.tr(),
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close confirm_gen_food
                              // Navigate back to food image capture screen
                              Navigator.pushNamed(
                                  context, NavigatorName.food_image_capture,
                                  arguments: {
                                    'timeframe': widget.timeframe,
                                    'timeframeId': widget.timeframeId,
                                  });
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.exit.tr(),
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

typedef TimeCallback = Function(DateTime?);

class DateMultiPicker extends StatefulWidget {
  final DateTime? initDate;
  final TimeCallback? callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime? selectedDate;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  final GlobalKey<CustomTimePickerState> _calendarDatePickerKey =
      GlobalKey<CustomTimePickerState>();

  @override
  void initState() {
    super.initState();
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate!.hour;
      selectedMinute = widget.initDate!.minute;
    } else {
      selectedDate = DateTime.now();
      selectedHour = DateTime.now().hour;
      selectedMinute = DateTime.now().minute;
    }
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
                            Text(R.string.pick_date.tr(),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon: Icon(Icons.close,
                                    color: R.color.color0xffBEC0C8),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null
                            ? DateTime.now()
                            : widget.initDate!,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (datetime) {
                          selectedDate = datetime ?? DateTime.now();
                          if (_calendarDatePickerKey.currentState != null) {
                            _calendarDatePickerKey.currentState!
                                .setSelectedDate(selectedDate!);
                          }
                        }),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(R.string.pick_time.tr(),
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTimePicker(
                        key: _calendarDatePickerKey,
                        initSelectedDate: selectedDate,
                        selectedHour: selectedHour,
                        selectedMinute: selectedMinute,
                        callback: (hour, minute) {
                          selectedHour = hour ?? DateTime.now().hour;
                          selectedMinute = minute ?? DateTime.now().minute;
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
                              borderRadius: BorderRadius.circular(21.5),
                              border: Border.all(
                                  color: R.color.greenGradientBottom),
                            ),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.greenGradientBottom,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            selectedDate = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedHour,
                                selectedMinute);

                            widget.callback!(selectedDate);

                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.greenGradientBottom,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text(R.string.yes.tr(),
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

typedef TimeHourCallback = Function(int?, int?);

class CustomTimePicker extends StatefulWidget {
  final int? selectedHour;
  final int? selectedMinute;
  final TimeHourCallback? callback;
  final DateTime? initSelectedDate;
  CustomTimePicker(
      {Key? key,
      this.selectedHour,
      this.selectedMinute,
      this.callback,
      this.initSelectedDate})
      : super(key: key);
  @override
  CustomTimePickerState createState() => CustomTimePickerState();
}

class CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int? selectedHour = 1;
  int? selectedMinute = 1;
  DateTime now = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initSelectedDate;
    selectedHour = now.hour;
    selectedMinute = now.minute;
    if (widget.selectedHour != null) {
      selectedHour = widget.selectedHour;
    }
    if (widget.selectedMinute != null) {
      selectedMinute = widget.selectedMinute;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour!);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute!);
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    if (_isTimeInFuture(selectedHour!, selectedMinute!)) {
      selectedHour = now.hour;
      selectedMinute = now.minute;
      hourController!.jumpToItem(selectedHour!);
      minuteController!.jumpToItem(selectedMinute!);
    }
    setState(() {});
  }

  // Check if a time is in the future
  bool _isTimeInFuture(int hour, int minute) {
    final now = DateTime.now();
    if (selectedDate != null &&
        selectedDate!.isBefore(DateTime(now.year, now.month, now.day))) {
      return false;
    }
    return now.hour < hour || (now.hour == hour && now.minute < minute);
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
                    // Prevent selecting future hours on current date
                    if (_isTimeInFuture(value, selectedMinute ?? 0)) {
                      // Reset to current hour and minute
                      selectedHour = now.hour;
                      selectedMinute = now.minute;
                      hourController!.jumpToItem(selectedHour!);
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedHour = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(24, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedHour == e
                                      ? R.color.greenGradientBottom
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
                    // Prevent selecting future minutes in the current hour
                    if (_isTimeInFuture(selectedHour ?? 0, value)) {
                      // Reset to current minute
                      selectedMinute = now.minute;
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedMinute = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(60, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedMinute == e
                                      ? R.color.greenGradientBottom
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList()))
      ],
    );
  }
}

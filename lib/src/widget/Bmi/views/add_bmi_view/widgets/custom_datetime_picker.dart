import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

typedef TimeCallback = Function(DateTime?);

class DateMultiPicker extends StatefulWidget {
  final DateTime? initDate;
  final TimeCallback? callback;

  DateMultiPicker({this.initDate, this.callback});

  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime? selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  ValueNotifier<DateTime> selectedDateNotifier = ValueNotifier(DateTime.now());

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedDateNotifier.value = widget.initDate!;
      selectedHour = widget.initDate!.hour;
      selectedMinute = widget.initDate!.minute;
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
                          selectedDate = datetime;
                          selectedDateNotifier.value = datetime!;
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
                    ValueListenableBuilder<DateTime>(
                      valueListenable: selectedDateNotifier,
                      builder: (context, selectedDate, _) {
                        return CustomTimePicker(
                          selectedHour: selectedHour,
                          selectedMinute: selectedMinute,
                          selectedDate: selectedDate,
                          callback: (hour, minute) {
                            selectedHour = hour ?? DateTime.now().hour;
                            selectedMinute = minute ?? DateTime.now().minute;
                          },
                        );
                      },
                    ),
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
                                  child: Text(R.string.cancel.tr(),
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
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedHour,
                                selectedMinute);

                            selectedDateNotifier.value = selectedDate!;

                            widget.callback!(selectedDate);

                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
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
  final DateTime selectedDate;
  final TimeHourCallback? callback;

  CustomTimePicker({
    this.selectedHour,
    this.selectedMinute,
    required this.selectedDate,
    this.callback,
  });

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int? selectedHour = 1;
  int? selectedMinute = 1;
  List<int> availableHours = [];
  List<int> availableMinutes = [];

  @override
  void initState() {
    super.initState();
    _updateAvailableTimes();
  }

  @override
  void didUpdateWidget(covariant CustomTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDate(oldWidget.selectedDate, widget.selectedDate)) {
      _updateAvailableTimes();
    }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _updateAvailableTimes() {
    final now = DateTime.now();
    final isToday = isSameDate(widget.selectedDate, now);

    // Giờ khả dụng
    availableHours = List.generate(isToday ? now.hour + 1 : 24, (i) => i);

    int newSelectedHour = widget.selectedHour ?? (isToday ? now.hour : 0);
    if (!availableHours.contains(newSelectedHour)) {
      newSelectedHour = availableHours.last;
    }

    // Phút khả dụng
    final isCurrentHour = isToday && newSelectedHour == now.hour;
    availableMinutes = List.generate(isCurrentHour ? now.minute + 1 : 60, (i) => i);

    int newSelectedMinute = widget.selectedMinute ?? (isCurrentHour ? now.minute : 0);
    if (!availableMinutes.contains(newSelectedMinute)) {
      newSelectedMinute = availableMinutes.last;
    }

    // Cập nhật giá trị đã chọn
    selectedHour = newSelectedHour;
    selectedMinute = newSelectedMinute;

    // Tạo controller mới đúng vị trí
    hourController?.dispose();
    minuteController?.dispose();

    hourController = FixedExtentScrollController(
      initialItem: availableHours.indexOf(selectedHour!),
    );
    hourController!.jumpToItem(availableHours.indexOf(selectedHour!));
    minuteController = FixedExtentScrollController(
      initialItem: availableMinutes.indexOf(selectedMinute!),
    );
    minuteController!.jumpToItem(availableMinutes.indexOf(selectedMinute!));

    // Gọi callback để thông báo thay đổi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.callback?.call(selectedHour, selectedMinute);
    });

    setState(() {});
  }


  void _updateMinutesBasedOnHour() {
    final now = DateTime.now();
    final isToday = isSameDate(widget.selectedDate, now);
    final isCurrentHour = isToday && selectedHour == now.hour;

    availableMinutes =
        List.generate(isCurrentHour ? now.minute + 1 : 60, (i) => i);
    if (!availableMinutes.contains(selectedMinute)) {
      selectedMinute = availableMinutes.last;
    }

    minuteController?.dispose();
    minuteController = FixedExtentScrollController(
      initialItem: availableMinutes.indexOf(selectedMinute!),
    );
  }

  @override
  void dispose() {
    hourController?.dispose();
    minuteController?.dispose();
    super.dispose();
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
                  if (value >= availableHours.length) return;
                  setState(() {
                    selectedHour = availableHours[value];
                    _updateMinutesBasedOnHour();
                    widget.callback?.call(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: availableHours
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
                  if (value >= availableMinutes.length) return;
                  setState(() {
                    selectedMinute = availableMinutes[value];
                    widget.callback?.call(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: availableMinutes
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

  return '${R.string.month} ${date.month}, ${date.year}';
}

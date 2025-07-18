import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

typedef DateTimeCallback = void Function(DateTime?);

class DateTimePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final DateTimeCallback? onDateTimeSelected;

  const DateTimePickerDialog({
    Key? key,
    this.initialDate,
    this.onDateTimeSelected,
  }) : super(key: key);

  @override
  _DateTimePickerDialogState createState() => _DateTimePickerDialogState();

  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    String? title,
  }) async {
    DateTime? selectedDateTime;

    await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => DateTimePickerDialog(
        initialDate: initialDate,
        onDateTimeSelected: (dateTime) {
          selectedDateTime = dateTime;
        },
      ),
    );

    return selectedDateTime;
  }
}

class _DateTimePickerDialogState extends State<DateTimePickerDialog> {
  late DateTime? selectedDate;
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      selectedDate = widget.initialDate;
      selectedHour = widget.initialDate!.hour;
      selectedMinute = widget.initialDate!.minute;
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {}, // Prevent dialog dismiss on inside tap
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildDatePicker(),
                    _buildTimeSectionTitle(),
                    SizedBox(height: 20),
                    _buildTimePicker(),
                    SizedBox(height: 20),
                    _buildActionButtons(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          R.string.pick_date.tr(),
          style: TextStyle(
              color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        IconButton(
            icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
            onPressed: () {
              Navigator.pop(context);
            })
      ]),
    );
  }

  Widget _buildDatePicker() {
    return CustomCalendarDatePicker(
        initialDate: selectedDate!,
        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
        lastDate: DateTime.now(),
        onDateChanged: (dateTime) {
          selectedDate = dateTime ?? DateTime.now();
        });
  }

  Widget _buildTimeSectionTitle() {
    return Row(
      children: [
        SizedBox(width: 16),
        Text(R.string.pick_time.tr(),
            style: TextStyle(
                color: R.color.black,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHourPicker(),
        SizedBox(width: 24),
        _buildMinutePicker(),
      ],
    );
  }

  Widget _buildHourPicker() {
    final FixedExtentScrollController hourController =
        FixedExtentScrollController(initialItem: selectedHour);

    return Container(
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
                .toList()));
  }

  Widget _buildMinutePicker() {
    final FixedExtentScrollController minuteController =
        FixedExtentScrollController(initialItem: selectedMinute);

    return Container(
        height: 150,
        width: 106,
        child: CupertinoPicker(
            scrollController: minuteController,
            selectionOverlay: null,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedMinute = value;
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
                .toList()));
  }

  Widget _buildActionButtons() {
    return Row(children: [
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
            final combinedDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedHour,
                selectedMinute);

            if (widget.onDateTimeSelected != null) {
              widget.onDateTimeSelected!(combinedDateTime);
            }

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
    ]);
  }
}

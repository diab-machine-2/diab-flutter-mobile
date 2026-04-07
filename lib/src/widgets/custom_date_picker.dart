import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    this.initDate,
    required this.callback,
    this.minDate,
    this.maxDate,
    this.selectedDate,
    this.activeDates,
  });

  final DateTime? initDate;
  final Function(DateTime) callback;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? selectedDate;
  final List<DateTime>? activeDates;

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate!;
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
            padding: const EdgeInsets.only(left: 16, right: 16),
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
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            R.string.pick_date.tr(),
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: R.color.color0xffBEC0C8),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.selectedDate ??
                            (widget.initDate == null
                                ? DateTime.now()
                                : widget.initDate!),
                        firstDate: widget.minDate ??
                            DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate:
                            widget.maxDate ?? DateTime.utc(275760, 09, 13),
                        activeDates: widget.activeDates,
                        onDateChanged: (datetime) {
                          selectedDate = datetime ?? DateTime.now();
                        }),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                color: R.color.grayBorder,
                                borderRadius: BorderRadius.circular(21.5),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              widget.callback(selectedDate);
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                color: R.color.mainColor,
                                borderRadius: BorderRadius.circular(21.5),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.yes.tr(),
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16)
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

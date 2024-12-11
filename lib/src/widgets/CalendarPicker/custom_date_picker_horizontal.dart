import 'dart:math' as math;
// import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/CalendarPicker/picker_helper.dart';
import 'date_utils.dart' as utils;

const Duration _monthScrollDuration = Duration(milliseconds: 200);

// const double _dayPickerRowHeight = 42.0;
// const int _maxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// One extra row for the day-of-week header.
// const double _maxDayPickerHeight =
//     _dayPickerRowHeight * (_maxDayPickerRowCount + 1);
// const double _monthPickerHorizontalPadding = 8.0;

// const int _yearPickerColumnCount = 3;
// const double _yearPickerPadding = 16.0;
// const double _yearPickerRowHeight = 52.0;
// const double _yearPickerRowSpacing = 8.0;

const double _datePickerWidth = 60.0;
const double _datePickerHeight = 64.0;

class CustomHorizontalDatePicker extends StatefulWidget {
  CustomHorizontalDatePicker({
    Key? key,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    List<DateTime>? activeDates,
    DateTime? currentDate,
    required int datesRange,
    required this.onDateChanged,
    this.selectableDayPredicate,
  })  : initialDate = utils.dateOnly(initialDate),
        this.activeDates = activeDates,
        firstDate = utils.dateOnly(firstDate),
        lastDate = utils.dateOnly(lastDate),
        currentDate = utils.dateOnly(currentDate ?? DateTime.now()),
        datesRange = datesRange,
        super(key: key) {
    assert(!this.lastDate.isBefore(this.firstDate),
        'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isBefore(this.firstDate),
        'initialDate ${this.initialDate} must be on or after firstDate ${this.firstDate}.');
    assert(!this.initialDate.isAfter(this.lastDate),
        'initialDate ${this.initialDate} must be on or before lastDate ${this.lastDate}.');
    assert(
        selectableDayPredicate == null ||
            selectableDayPredicate!(this.initialDate),
        'Provided initialDate ${this.initialDate} must satisfy provided selectableDayPredicate.');
  }

  /// The initially selected [DateTime] that the picker should display.
  final DateTime initialDate;

  List<DateTime>? activeDates;

  /// The earliest allowable [DateTime] that the user can select.
  final DateTime firstDate;

  /// The latest allowable [DateTime] that the user can select.
  final DateTime lastDate;

  /// The [DateTime] representing today. It will be highlighted in the day grid.
  final DateTime currentDate;

  /// Called when the user selects a date in the picker.
  final ValueChanged<DateTime?> onDateChanged;

  /// Function to provide full control over which dates in the calendar can be selected.
  final SelectableDayPredicate? selectableDayPredicate;

  /// Display range of dates
  final int datesRange;

  @override
  _CustomCalendarDatePickerState createState() =>
      _CustomCalendarDatePickerState();
}

class _CustomCalendarDatePickerState extends State<CustomHorizontalDatePicker> {
  bool _announcedInitialDate = false;
  DateTime? _currentDisplayedMonthDate;
  DateTime? _selectedDate;
  late MaterialLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _initWidgetState();
  }

  @override
  void didUpdateWidget(CustomHorizontalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initWidgetState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _localizations = MaterialLocalizations.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(
        _localizations.formatFullDate(_selectedDate!),
        Directionality.of(context),
      );
    }
  }

  void _initWidgetState() {
    _currentDisplayedMonthDate =
        DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged.call(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    return Stack(
      children: <Widget>[
        SizedBox(
          child: _buildHorizontalPicker(),
        ),
      ],
    );
  }

  Widget _buildHorizontalPicker() {
    final days = generateDays();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: _datePickerHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.datesRange,
        itemBuilder: (context, index) {
          final date = days[index];
          final dayLabel = DateUtil.weekDayToString(date);

          String formattedDate = DateFormat('dd/MM').format(date);
          final isSelected = DateUtil.isSameDate(date, _selectedDate!);
          final hasSlot = isHasSlot(date);
          return InkWell(
            onTap: () {
              if (hasSlot) {
                _handleDayChanged(date);
              }
            },
            child: Container(
              width: _datePickerWidth,
              height: _datePickerHeight,
              margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 10,
                  right: index == widget.datesRange - 1
                      ? 16
                      : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: PickerHelper.getBorderColorByState(
                      isSelected: isSelected, hasSlot: hasSlot),
                ),
                color: PickerHelper.getContainerColorByState(
                    isSelected: isSelected, hasSlot: hasSlot),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(
                      color: PickerHelper.getTextColorByState(
                          isSelected: isSelected, hasSlot: hasSlot),
                      fontWeight: PickerHelper.getTextFontWeightByState(
                          isSelected: isSelected),
                      fontSize: 13,
                      fontFamily: 'sfpro',
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: PickerHelper.getTextColorByState(
                          isSelected: isSelected, hasSlot: hasSlot),
                      fontWeight: PickerHelper.getTextFontWeightByState(
                          isSelected: isSelected),
                      fontSize: 15,
                      fontFamily: 'sfpro',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<DateTime> generateDays() {
    final List<DateTime> days = [];
    final DateTime today = DateTime.now();

    for (int i = 0; i < widget.datesRange; i++) {
      days.add(today.add(Duration(days: i)));
    }

    return days;
  }

  bool isHasSlot(DateTime selectedDate) {
    return widget.activeDates?.any(
            (activeDate) => DateUtil.isSameDate(activeDate, selectedDate)) ??
        false;
  }
}

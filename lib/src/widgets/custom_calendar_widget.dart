import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({this.time, this.onSelectDate});

  final DateTime? time;
  final Function(DateTime)? onSelectDate;

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _time;
  DateTime? selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _time = widget.time ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${R.string.month} ${_time.month}, ${_time.year}',
                style: TextStyle(
                    color: R.color.greenGradientBottom,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: R.color.greenGradientBottom,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  _time = DateTime(_time.year, _time.month - 1, _time.day);
                  setState(() {});
                },
                icon: Icon(
                  Icons.chevron_left_rounded,
                  size: 32,
                  color: R.color.greenGradientBottom,
                ),
              ),
              IconButton(
                onPressed: () {
                  _time = DateTime(_time.year, _time.month + 1, _time.day);
                  setState(() {});
                },
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: R.color.greenGradientBottom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDayInWeekTitleList(),
          const SizedBox(height: 8),
          ..._buildListDayInMonth(),
        ],
      ),
    );
  }

  Widget _buildDayInWeekTitleList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        7,
        (index) {
          final String title = index == 0 ? 'CN' : 'T${index + 1}';
          return Container(
            alignment: Alignment.center,
            width: 42,
            child: Text(
              title,
              style: TextStyle(
                color: R.color.labelColor.withOpacity(0.3),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }

  DateTime getFirstSundayOfMonth(DateTime dateTime) {
    dateTime = DateTime(dateTime.year, dateTime.month, 1);
    if (dateTime.weekday == 7) return dateTime;
    return dateTime.subtract(Duration(days: dateTime.weekday));
  }

  List<Widget> _buildListDayInMonth() {
    final List<Widget> weekListInMonth = [];
    int i = 0;
    DateTime tmpTime = getFirstSundayOfMonth(_time);
    while (isPreviousMonth(tmpTime, _time) && i < 40) {
      weekListInMonth.add(_buildDayInWeekRow(tmpTime));
      tmpTime = tmpTime.add(
        const Duration(days: 7),
      );
      i++;
    }
    return weekListInMonth;
  }

  Widget _buildDayInWeekRow(DateTime firstDayOfWeek) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final DateTime dateTime = firstDayOfWeek.add(Duration(days: index));
        final DateTime now = DateTime.now();
        final bool isActive = dateTime.isAfter(now) ||
            dateTime.day == now.day &&
                dateTime.month == now.month &&
                dateTime.year == now.year;
        return _buildSingleDayInWeek(
            dateTime: dateTime,
            isActive: isActive,
            onSelected: (time) {
              selectedDate = time;
              if (widget.onSelectDate != null) {
                widget.onSelectDate!(time);
              }
              setState(() {});
            });
      }),
    );
  }

  Widget _buildSingleDayInWeek({
    required DateTime dateTime,
    required bool isActive,
    required Function(DateTime dateTime) onSelected,
  }) {
    final String day = dateTime.month == _time.month ? '${dateTime.day}' : '';
    final bool isSelected = isSelectedDate(dateTime);
    return InkWell(
      onTap: () {
        onSelected(dateTime);
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
        width: 42,
        decoration: BoxDecoration(
          color: isSelectedDate(dateTime) && day.isNotEmpty
              ? R.color.main_6
              : R.color.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          day,
          style: TextStyle(
            color: isActive
                ? R.color.greenGradientBottom
                : R.color.captionColorGray,
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  bool isSelectedDate(DateTime dateTime1) =>
      dateTime1.year == selectedDate?.year &&
      dateTime1.month == selectedDate?.month &&
      dateTime1.day == selectedDate?.day;

  bool isPreviousMonth(DateTime currentDateTime, DateTime targetDateTime) {
    if (currentDateTime.month == 12 && targetDateTime.month == 1) {
      return currentDateTime.year < targetDateTime.year;
    }
    if (targetDateTime.month == 12) {
      return currentDateTime.month <= targetDateTime.month &&
          currentDateTime.year <= targetDateTime.year;
    }
    return currentDateTime.month <= targetDateTime.month;
  }
}

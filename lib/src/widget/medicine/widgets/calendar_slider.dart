import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';

typedef OnDateSelectedCallback = void Function(DateTime date);

class CalendarSlider extends StatefulWidget {
  const CalendarSlider({
    super.key,
    required this.onDateSelected,
    this.initialDate,
  });

  final OnDateSelectedCallback onDateSelected;
  final DateTime? initialDate;

  @override
  State<CalendarSlider> createState() => _CalendarSliderState();
}

class _CalendarSliderState extends State<CalendarSlider> {
  late DateTime _selectedDate;
  late List<DateTime> _dates;
  final ScrollController _scrollController = ScrollController();
  final _itemWidth = 72.0;

  @override
  void initState() {
    super.initState();
    // Use the provided initialDate or default to today.
    _selectedDate = widget.initialDate ?? DateTime.now();
    _dates = _generateDates();

    // Add a listener to the scroll controller.
    _scrollController.addListener(_onScroll);

    // Call the callback with the initial selected date.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(_selectedDate, false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _generateDates() {
    final currentDateTime = DateTime.now();
    final now = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);
    final start = now.subtract(const Duration(days: 30));
    final end = now.add(const Duration(days: 30));
    final dates = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      dates.add(start.add(Duration(days: i)));
    }
    return dates;
  }

  void _scrollToDate(DateTime date, bool isAnim) {
    final index = _dates.indexWhere(
      (d) => d.day == date.day && d.month == date.month && d.year == date.year,
    );
    if (index != -1) {
      final screenWidth = MediaQuery.of(context).size.width;
      final centerOffset = (screenWidth / 2) - (_itemWidth / 2);
      final predictOffset = index * _itemWidth + 12 + (index - 1) * 8 /*padding*/ - centerOffset;
      if (predictOffset >= 0.0) {
        if (isAnim) {
          _scrollController.animateTo(
            predictOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        } else {
          _scrollController.jumpTo(predictOffset);
        }
      }
    }
  }

  /// Checks the scroll position and adds more dates if the user is near the end or beginning.
  void _onScroll() {
    // Threshold to trigger loading.
    const threshold = 100.0;

    // Check if the user has scrolled to the end.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      _addMoreDates(isEnd: true);
    }

    // Check if the user has scrolled to the beginning.
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + threshold) {
      _addMoreDates(isEnd: false);
    }
  }

  /// Adds a new set of dates to the list.
  void _addMoreDates({required bool isEnd}) {
    final newDates = <DateTime>[];
    const daysToAdd = 30;

    if (isEnd) {
      // Add dates to the end.
      final lastDate = _dates.last;
      for (int i = 1; i <= daysToAdd; i++) {
        newDates.add(lastDate.add(Duration(days: i)));
      }
      setState(() {
        _dates.addAll(newDates);
      });
    } else {
      // Add dates to the beginning.
      final firstDate = _dates.first;
      for (int i = 1; i <= daysToAdd; i++) {
        newDates.add(firstDate.subtract(Duration(days: i)));
      }
      setState(() {
        // We add to the front and need to adjust the scroll position.
        _dates.insertAll(0, newDates.reversed);
        final currentPosition = _scrollController.position.pixels;
        _scrollController.jumpTo(currentPosition + (daysToAdd * 80.0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String headerText;
    if (DateFormat('dd/MM/yyyy').format(_selectedDate) ==
        DateFormat('dd/MM/yyyy').format(DateTime.now())) {
      headerText = 'Hôm nay - ${DateFormat('dd/MM/yyyy').format(_selectedDate)}';
    } else {
      headerText = DateFormat('dd/MM/yyyy').format(_selectedDate);
    }

    return Column(
      children: [
        Container(
          height: 68,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  width: 24,
                  height: 24,
                  R.icons.ic_chevron_left,
                  color: Color(0xFF5E6566),
                ),
                onPressed: () {
                  // Navigate to the previous day.
                  final newDate = _selectedDate.subtract(const Duration(days: 1));
                  setState(() {
                    _selectedDate = newDate;
                  });
                  widget.onDateSelected(newDate);
                  _scrollToDate(newDate, true);
                },
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFDADEDF)),
                  ),
                  child: Text(
                    headerText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1.46,
                      letterSpacing: 0.4,
                      color: Color(0xFF172823),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                    width: 24,
                    height: 24,
                    R.icons.ic_chevron_right,
                    color: Color(0xFF5E6566)
                ),
                onPressed: () {
                  // Navigate to the next day.
                  final newDate = _selectedDate.add(const Duration(days: 1));
                  setState(() {
                    _selectedDate = newDate;
                  });
                  widget.onDateSelected(newDate);
                  _scrollToDate(newDate, true);
                },
              ),
            ],
          ),
        ),
        // The main calendar slider.
        Container(
          height: 76,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          color: const Color(0xFFFFFFFF),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final dayOfWeek = DateFormat('E', 'vi_VN').format(date);

              // Individual date item (the selectable box).
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  width: _itemWidth,
                  height: 60,
                  margin: index == 0 ? EdgeInsets.fromLTRB(12, 0, 8, 0) : index == _dates.length - 1 ? EdgeInsets.only(right: 12) : EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? const Color(0xFF008479) : const Color(0xFFDADEDF),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        // Format the weekday to be in Vietnamese.
                        dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                          height: 1.46,
                          letterSpacing: 0.4,
                          color: isSelected ? Color(0xFF008479) : Color(0xFF111515),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM').format(date),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 15,
                          height: 1.46,
                          color: isSelected ? Color(0xFF008479) : Color(0xFF111515),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

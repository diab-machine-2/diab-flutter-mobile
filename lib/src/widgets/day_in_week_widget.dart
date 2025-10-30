// day_in_week_widget.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DayInWeekWidget extends StatelessWidget {
  const DayInWeekWidget({
    Key? key,
    required this.data,
    required this.mark,
    required this.currentDayIndex,
    this.showDateTime = false,
    this.dashHeight = 1,
    this.activeDashColor,
    this.inactiveDashColor,
    required this.onSelectDay,
  }) : super(key: key);

  final List<DayInWeekData> data;
  final int mark;
  final int currentDayIndex;
  final bool showDateTime;
  final double dashHeight;
  final Color? activeDashColor;
  final Color? inactiveDashColor;
  final Function(int selectedDay) onSelectDay;

  // -----------------------------------------------------------------
  //  Fixed width for every title (weekday) block
  // -----------------------------------------------------------------
  static const double _titleWidth = 42.0; // <-- 42 px

  // -----------------------------------------------------------------
  //  Dash length = (available width – N * titleWidth) / (N-1)
  // -----------------------------------------------------------------
  double _dashLength(double maxWidth) {
    if (data.length < 2) return 0;
    return (maxWidth - data.length * _titleWidth) / (data.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty
        ? const SizedBox()
        : LayoutBuilder(
            builder: (context, constraints) {
              final double rawDashLen = _dashLength(constraints.maxWidth);
              final bool needsScrollWidth = rawDashLen < 0;
              final double dashLen =
                  needsScrollWidth ? 8.0 : math.max(0.0, rawDashLen);
              final int n = data.length;
              final double requiredWidth = n > 0
                  ? n * _titleWidth + (n - 1) * dashLen
                  : constraints.maxWidth;

              final content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(dashLen),
                  const GapH(8),
                  _buildIconRow(dashLen),
                ],
              );

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: needsScrollWidth
                    ? SizedBox(width: requiredWidth, child: content)
                    : content,
              );
            },
          );
  }

  Widget _buildTitleRow(double dashLen) {
    return Row(
      children: List.generate(data.length * 2 - 1, (i) {
        if (i.isOdd) {
          // dash placeholder (same length as real dash)
          return SizedBox(width: dashLen);
        }

        final idx = i ~/ 2;
        final day = data[idx];
        final selected = idx == currentDayIndex;

        return InkWell(
          onTap: () => onSelectDay(idx),
          child: _titleBlock(
            title: day.title,
            dateTime: day.dateTime,
            isSelected: selected,
          ),
        );
      }),
    );
  }

  Widget _buildIconRow(double dashLen) {
    final int n = data.length;
    final double totalWidth = n > 0 ? n * _titleWidth + (n - 1) * dashLen : 0;

    return SizedBox(
      width: totalWidth,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Center-to-center dashes only between icons
          for (int i = 0; i < n - 1; i++)
            Positioned(
              left: i * (_titleWidth + dashLen) + (_titleWidth / 2),
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: dashLen + _titleWidth, // span center-to-center
                  height: i >= mark ? 1 : 4, // future thin, past thick
                  color: i >= mark
                      ? (inactiveDashColor ?? R.color.color0xffE5E5E5)
                      : (activeDashColor ?? R.color.accentColor),
                ),
              ),
            ),

          // Foreground icons centered in their 42px slots
          Row(
            children: List.generate(n * 2 - 1, (i) {
              if (i.isOdd) {
                return SizedBox(width: dashLen);
              }

              final int idx = i ~/ 2;
              final day = data[idx];
              final bool selected = idx == currentDayIndex;
              final bool isToday = day.isToday ?? false;

              return SizedBox(
                width: _titleWidth,
                child: Center(
                  child: InkWell(
                    onTap: () => onSelectDay(idx),
                    child: day.dayStatus.dayStatusIcon(selected, isToday),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _titleBlock({
    required String title,
    int? dateTime,
    required bool isSelected,
  }) {
    final String dayTitle = dateTime == null
        ? ''
        : '${DateTime.fromMillisecondsSinceEpoch(dateTime * 1000, isUtc: true).toLocal().day}/${DateTime.fromMillisecondsSinceEpoch(dateTime * 1000, isUtc: true).toLocal().month}';

    return SizedBox(
      width: _titleWidth,
      child: Column(
        children: [
          // ---- weekday text (T2, T3 …) ----
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(color: R.color.accentColor, width: 1.5),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),

          // ---- optional date (dd/mm) ----
          if (showDateTime)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                dayTitle,
                style: TextStyle(
                  color: R.color.grey_1,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class DayInWeekData {
  DayInWeekData({
    required this.title,
    required this.dayStatus,
    this.dateTime,
    this.isToday,
  });

  final String title;
  final CompletionStatus dayStatus;
  final int? dateTime;
  final bool? isToday;
}

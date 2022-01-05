import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

class DayInWeekWidget extends StatelessWidget {
  const DayInWeekWidget({
    Key? key,
    required this.data,
    required this.mark,
    required this.currentDayIndex,
    required this.onSelectDay,
  }) : super(key: key);
  final List<DayInWeekData> data;
  final int mark;
  final int currentDayIndex;
  final Function(int selectedDay) onSelectDay;

  @override
  Widget build(BuildContext context) {
    return data.isNotEmpty != true
        ? const SizedBox()
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    (data.length * 2) - 1,
                    (index) {
                      return index.isOdd
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 11.5),
                              width: _getDashLength(constraints.maxWidth),
                              height: 1,
                              color: index ~/ 2 >= mark
                                  ? R.color.grayBorder
                                  : R.color.green,
                            )
                          : _buildSingleDay(
                              status: data[index ~/ 2].dayStatus,
                              isSelected: index ~/ 2 == currentDayIndex,
                              title: data[index ~/ 2].title,
                              day: data[index ~/ 2].dateTime,
                              onTap: () {
                                onSelectDay(index ~/ 2);
                              });
                    },
                  ),
                ),
              );
            },
          );
  }

  bool get showDay {
    for (final DayInWeekData dayInWeekData in data) {
      if (dayInWeekData.dateTime == null) return false;
    }
    return true;
  }

  double _getDashLength(double maxWidth) {
    return (maxWidth - 168) / 6;
  }

  Widget _buildSingleDay(
      {required CompletionStatus status,
      required bool isSelected,
      required String title,
      int? day,
      VoidCallback? onTap}) {
    final DateTime today =
        DateTime.fromMillisecondsSinceEpoch((day ?? 0) * 1000);
    final String dayTitle = '${today.day}/${today.month}';
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            width: 24,
            child: Text(
              title,
              style: TextStyle(
                color: R.color.grey_1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: 24,
            child: Visibility(
              visible: day != null,
              child: Text(
                dayTitle,
                style: TextStyle(
                  color: R.color.grey_1,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          status.dayStatusIcon(isSelected),
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
  });

  String title;
  CompletionStatus dayStatus;
  int? dateTime;
}

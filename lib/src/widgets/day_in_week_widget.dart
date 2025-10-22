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
                              margin: EdgeInsets.only(
                                  bottom: index ~/ 2 >= mark
                                      ? 15
                                      : 13), // Center the dash line with the circle
                              width: _getDashLength(constraints.maxWidth),
                              height: index ~/ 2 >= mark
                                  ? 2
                                  : 4, // Future days: thickness 1, Past days: thickness 2
                              color: index ~/ 2 >= mark
                                  ? (inactiveDashColor ??
                                      R.color.color0xffE5E5E5)
                                  : (activeDashColor ?? R.color.accentColor),
                            )
                          : _buildSingleDay(
                              status: data[index ~/ 2].dayStatus,
                              isSelected: index ~/ 2 == currentDayIndex,
                              title: data[index ~/ 2].title,
                              day: data[index ~/ 2].dateTime,
                              isToday: data[index ~/ 2].isToday,
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
    return (maxWidth - 190) / 7;
  }

  Widget _buildSingleDay(
      {required CompletionStatus status,
      required bool isSelected,
      required String title,
      bool? isToday,
      int? day,
      VoidCallback? onTap}) {
    DateTime today =
        DateTime.fromMillisecondsSinceEpoch((day ?? 0) * 1000, isUtc: true);
    today = today.toLocal();
    final String dayTitle = '${today.day}/${today.month}';
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            width: 30,
            child: Text(
              title,
              style: TextStyle(
                color: R.color.grey_1,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Visibility(
            visible: showDateTime,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: 30,
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
          GapH(4),
          status.dayStatusIcon(isSelected, isToday ?? false),
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

  String title;
  CompletionStatus dayStatus;
  int? dateTime;
  bool? isToday;
}

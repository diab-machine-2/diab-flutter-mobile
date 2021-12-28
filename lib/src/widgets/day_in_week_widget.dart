import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/my_plan_screens/my_plan/models/completion_status.dart';

const List<String> title = [
  'T7',
  'CN',
  'T2',
  'T3',
  'T4',
  'T5',
  'T6',
  'T7',
  'CN',
];

const List<CompletionStatus> days = [
  CompletionStatus.not_start_yet,
  CompletionStatus.not_completed,
  CompletionStatus.not_start_yet,
  CompletionStatus.completed,
  CompletionStatus.studying,
  CompletionStatus.not_completed,
  CompletionStatus.not_start_yet,
  CompletionStatus.not_completed,
  CompletionStatus.completed,
];

class DayInWeekWidget extends StatefulWidget {
  const DayInWeekWidget({Key? key}) : super(key: key);

  @override
  _DayInWeekWidgetState createState() => _DayInWeekWidgetState();
}

class _DayInWeekWidgetState extends State<DayInWeekWidget> {
  final mark = 5;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              (days.length * 2) - 1,
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
                        status: CompletionStatus.not_start_yet,
                        isSelected: false,
                        title: title[index ~/ 2],
                        onTap: () {});
              },
            ),
          ),
        );
      },
    );
  }

  double _getDashLength(double maxWidth) {
    return (maxWidth - 112) / 6;
  }

  Widget _buildSingleDay(
      {required CompletionStatus status,
      required bool isSelected,
      required String title,
      VoidCallback? onTap}) {
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
          const SizedBox(height: 4),
          status.dayStatusIcon(isSelected),
        ],
      ),
    );
  }
}

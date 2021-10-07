import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';

class DayInWeekButtons extends StatefulWidget {
  const DayInWeekButtons({this.initDay = 0, required this.onSlectDay});

  final int initDay;
  final Function(int index) onSlectDay;

  @override
  _DayInWeekButtonsState createState() => _DayInWeekButtonsState();
}

class _DayInWeekButtonsState extends State<DayInWeekButtons> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initDay;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          return _buildDayOfTheWeekSingleButton(
              dayTitle: Utils.getDayInWeekTitle(index),
              isSelected: index == selectedIndex,
              onTap: () {
                selectedIndex = index;
                widget.onSlectDay(index);
                setState(() {});
              });
        }),
      ),
    );
  }

  Widget _buildDayOfTheWeekSingleButton({
    required String dayTitle,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? R.color.mainColor : R.color.grayBorder,
          ),
          color: isSelected ? R.color.main_6 : Colors.transparent,
        ),
        child: Text(
          dayTitle,
          style: TextStyle(
            color: isSelected ? R.color.mainColor : R.color.primaryGreyColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

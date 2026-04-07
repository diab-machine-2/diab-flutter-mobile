
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';

class EmptyMedicineSchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            R.icons.ic_empty_medicine_schedule,
            width: 167,
            height: 116,
          ),
          SizedBox(height: 14),
          Text(
            R.string.today_you_have_no_schedule_today.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.46,
              letterSpacing: 0.4,
              color: Color(0xFF3E3F3F),
            ),
          ),
          SizedBox(height: 4),
          Text(
            R.string.add_medicine_so_diab_remind_you_on_time.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 1.46,
              letterSpacing: 0.4,
              color: Color(0xFF636A6B),
            ),
          )
        ],
      ),
    );
  }
}

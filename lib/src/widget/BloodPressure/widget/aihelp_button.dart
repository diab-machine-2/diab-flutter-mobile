import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_page.dart';

import '../bloodpressure_result.dto.dart';

class AIHelpButton extends StatelessWidget {
  const AIHelpButton({super.key, required this.rangeType});

  final BloodPressureRangeType rangeType;

  bool get _isHighPressure =>
      rangeType == BloodPressureRangeType.high1 ||
      rangeType == BloodPressureRangeType.high2 ||
      rangeType == BloodPressureRangeType.very_high;

  bool get _isLowPressure =>
      rangeType == BloodPressureRangeType.low ||
      rangeType == BloodPressureRangeType.normal_high;

  void _actionByRangeType(BuildContext context) async {
    if (_isLowPressure) {
      // Redirect to "Redirect ‘AI Chat’"
      Observable.instance.notifyObservers([], notifyName: Const.NAVIGATE_TO_CHAT_TAB);
    } else if (_isHighPressure) {
      // Redirect ‘Tư vấn sống khoẻ’ (PSC Booking Online 816, màn hình chọn nhu cầu tư vấn)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DsmesAppointmentPage(
            bloodPressureConsult: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isHighPressure && !_isLowPressure) {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () => _actionByRangeType(context),
      child: Center(
        child: Text(
          _isLowPressure
              ? 'Hỏi đáp cùng Trợ lý sống khoẻ'
              : 'Đặt lịch tư vấn với chuyên gia',
          style: TextStyle(
            color: R.color.mainColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.color0xffE1FAF8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        fixedSize: Size(double.infinity, 32),
        elevation: 0,
      ),
    );
  }
}

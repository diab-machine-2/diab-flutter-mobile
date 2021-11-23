import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import '../models/create_goal_status.dart';

class CustomTopProgressBar extends StatelessWidget {
  const CustomTopProgressBar(this.status);
  final CreateGoalStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildSingleStatus(index: 0),
            Expanded(
              child: Container(
                height: 1,
                color: status.index < 1 ? R.color.grayBorder : R.color.green,
              ),
            ),
            _buildSingleStatus(index: 1),
            Expanded(
              child: Container(
                height: 1,
                color: status.index < 2 ? R.color.grayBorder : R.color.green,
              ),
            ),
            _buildSingleStatus(index: 2),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTextLayout(
                text: 'Chọn loại\nmục tiêu',
                alignment: Alignment.centerLeft,
                textAlign: TextAlign.left),
            _buildTextLayout(
                text: 'Chi tiết\nmục tiêu',
                alignment: Alignment.center,
                textAlign: TextAlign.center),
            _buildTextLayout(
                text: 'Hoàn thành',
                alignment: Alignment.centerRight,
                textAlign: TextAlign.right),
          ],
        )
      ],
    );
  }

  Widget _buildSingleStatus({required int index}) {
    late final Widget child;
    late final Color color;
    if (status.index > index) {
      child = Icon(
        Icons.check_rounded,
        color: R.color.white,
        size: 16,
      );
      color = R.color.greenGradientBottom;
    } else if (status.index == index) {
      child = Image.asset(
        R.drawable.ic_learning,
        color: R.color.white,
        width: 16,
        height: 16,
      );
      color = R.color.green;
    } else {
      child = const SizedBox();
      color = R.color.grayBorder;
    }
    return Container(
        width: 24,
        height: 24,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: child);
  }

  Widget _buildTextLayout(
      {required String text,
      required Alignment alignment,
      required TextAlign textAlign}) {
    return Container(
      width: 70,
      alignment: alignment,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: R.color.grey_1,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

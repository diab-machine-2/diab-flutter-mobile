import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import '../models/create_goal_status.dart';

class CustomTopProgressBar extends StatelessWidget {
  const CustomTopProgressBar(this.status, {required this.onSelect});
  final CreateGoalStatus status;
  final Function(CreateGoalStatus) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildSingleStatus(
                index: 0,
                onTap: () {
                  onSelect(CreateGoalStatus.select_type);
                }),
            Expanded(
              child: Container(
                height: 1,
                color: status.index < 1 ? R.color.grayBorder : R.color.green,
              ),
            ),
            _buildSingleStatus(
                index: 1,
                onTap: () {
                  onSelect(CreateGoalStatus.setup);
                }),
            Expanded(
              child: Container(
                height: 1,
                color: status.index < 2 ? R.color.grayBorder : R.color.green,
              ),
            ),
            _buildSingleStatus(
                index: 2,
                onTap: () {
                  onSelect(CreateGoalStatus.complete);
                }),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTextLayout(
                text: R.string.select_smart_goal.tr(),
                alignment: Alignment.centerLeft,
                textAlign: TextAlign.left),
            _buildTextLayout(
                text: R.string.setup_smart_goal.tr(),
                alignment: Alignment.center,
                textAlign: TextAlign.center),
            _buildTextLayout(
                text: R.string.complete_lesson.tr(),
                alignment: Alignment.centerRight,
                textAlign: TextAlign.right),
          ],
        )
      ],
    );
  }

  Widget _buildSingleStatus({required int index, required VoidCallback onTap}) {
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
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: child),
    );
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

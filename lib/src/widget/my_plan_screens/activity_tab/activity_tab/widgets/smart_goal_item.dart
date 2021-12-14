import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medical/res/R.dart';
import '../models/schedule_type.dart';

class SmartGoalItem extends StatelessWidget {
  const SmartGoalItem(
      {required this.type,
      required this.name,
      required this.frequency,
      required this.isDone,
      required this.onTap,
      required this.onRemove});
  final ScheduleType type;
  final String name;
  final String frequency;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        actionPane: const SlidableDrawerActionPane(),
        secondaryActions: [
          Container(
            margin: const EdgeInsets.only(left: 4),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: IconSlideAction(
              color: R.color.color0xffFF5552,
              iconWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(R.drawable.ic_trash2, width: 24, height: 24),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Huỷ mục tiêu',
                          style: TextStyle(
                              color: R.color.white, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center),
                    ),
                  ]),
              onTap: () {},
            ),
          ),
        ],
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: R.color.color0xffE5E5E5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: R.color.grey_6,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    type.icon,
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type == ScheduleType.custom ? name : type.title,
                        style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      if (frequency.isNotEmpty) const SizedBox(height: 4),
                      if (frequency.isNotEmpty)
                        Text(
                          frequency,
                          style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDone ? R.color.greenGradientBottom : R.color.white,
                    border: isDone ? null : Border.all(color: R.color.grey_2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isDone ? R.color.white : R.color.grey_2,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

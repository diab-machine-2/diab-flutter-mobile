import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import '../schema/home_schema.dart';

typedef ReminderCallback = void Function(HomeReminderData reminder);

class HomeReminder extends StatelessWidget {
  const HomeReminder({
    super.key,
    required this.reminders,
    required this.expanded,
    required this.onExpand,
    required this.onCollapse,
    required this.onAdd,
    required this.onItemTap,
    this.loading = false,
  });

  final bool loading;

  final List<HomeReminderData> reminders;
  final bool expanded;

  final VoidCallback onAdd;
  final ReminderCallback onItemTap;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = reminders.isEmpty;
    final bool isHaveMore = reminders.length > 2;
    return Column(
      children: [
        // Header
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(
        //       "Lịch nhắc nhở",
        //       style: TextStyle(
        //         fontSize: 18.0,
        //         fontWeight: FontWeight.bold,
        //         color: R.color.color0xff27272A,
        //       ),
        //     ),
        //     SizedBox(
        //       height: 24.0,
        //       child: loading
        //           ? Align(
        //               alignment: Alignment.centerRight,
        //               child: Padding(
        //                 padding: const EdgeInsets.only(right: 4.0),
        //                 child: SizedBox(
        //                   child: CircularProgressIndicator(strokeWidth: 2.0),
        //                   width: 16.0,
        //                   height: 16.0,
        //                 ),
        //               ),
        //             )
        //           : InkWell(
        //               onTap: onAdd,
        //               child: Row(
        //                 children: [
        //                   Icon(Icons.add,
        //                       color: R.color.greenGradientBottom, size: 20.0),
        //                   const SizedBox(width: 6.0),
        //                   Text(
        //                     "Thêm",
        //                     style: TextStyle(
        //                       fontSize: 14.0,
        //                       fontWeight: FontWeight.bold,
        //                       color: R.color.greenGradientBottom,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //     ),
        //   ],
        // ),

        const SizedBox(height: 16.0),

        if (loading && isEmpty) const SizedBox(height: 56.0),

        if (!isEmpty && !isHaveMore)
          for (var reminder in reminders) _buildActivityItem(reminder),

        if (!isEmpty && isHaveMore && !expanded)
          for (var reminder in reminders.take(2)) _buildActivityItem(reminder),

        if (!isEmpty && isHaveMore && expanded)
          for (var reminder in reminders) _buildActivityItem(reminder),
      ],
    );
  }

  Widget _buildActivityItem(HomeReminderData reminder) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => onItemTap(reminder),
        child: Container(
          padding: const EdgeInsets.fromLTRB(7, 15, 10, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 12,
                spreadRadius: 0,
                color: Color(0xFF000000).withOpacity(0.12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 58,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      reminder.icon,
                      width: 24.0,
                      height: 24.0,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      R.string.reminder.tr(),
                      style: TextStyle(
                        fontSize: 10.0,
                        color: R.color.reminder_color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: R.color.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                reminder.time,
                style: TextStyle(
                  fontSize: 13.0,
                  color: R.color.color0xff666666,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

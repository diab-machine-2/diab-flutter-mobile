import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import '../schema/measurement_schema.dart';

class HomeReminder extends StatelessWidget {
  const HomeReminder({
    super.key,
    required this.reminders,
    required this.onAdd,
  });

  final List<HomeReminderData> reminders;

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lịch nhắc nhở",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: R.color.color0xff27272A,
                ),
              ),
              InkWell(
                onTap: onAdd,
                child: Row(
                  children: [
                    Icon(Icons.add, color: R.color.greenGradientBottom, size: 20.0),
                    const SizedBox(width: 6.0),
                    Text(
                      "Thêm",
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          if (reminders.isEmpty)
            SizedBox(
              height: 164.0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "empty_reminder".tr(),
                      style: TextStyle(
                        fontSize: 14.0,
                        height: 20.0 / 14.0,
                        color: R.color.primaryGreyColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24.0),

                    // button
                    SizedBox(
                      width: 188.0,
                      child: InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: R.color.greenGradientBottom,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                R.drawable.ic_home_plus,
                                width: 16.0,
                                height: 16.0,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                "Thêm nhắc nhở",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0,
                                  height: 16.0 / 13.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          for (var reminder in reminders) _buildActivityItem(reminder),
        ],
      ),
    );
  }

  Widget _buildActivityItem(HomeReminderData reminder) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            reminder.icon,
            width: 32.0,
            height: 32.0,
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
    );
  }
}

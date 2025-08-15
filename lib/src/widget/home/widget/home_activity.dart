import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

import '../schema/home_schema.dart';

typedef OnActivityTap = void Function(HomeActivityData activity);

class HomeActivity extends StatelessWidget {
  const HomeActivity({
    super.key,
    required this.activities,
    required this.onExpand,
    required this.onCollapse,
    required this.onAddActivity,
    required this.onViewMore,
    required this.onActivityTap,
    this.expanded = false,
    this.loading = false,
    this.hasReminder = false,
  });

  final bool loading;

  final List<HomeActivityData> activities;
  final bool expanded;
  final bool hasReminder;

  final VoidCallback onViewMore;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final VoidCallback onAddActivity;
  final OnActivityTap onActivityTap;

  @override
  Widget build(BuildContext context) {
    List<HomeActivityData> renderingActivities =
        activities.where((e) => e.smartGoal.state != 1).toList();
    bool isFinishedAll = renderingActivities.isEmpty && activities.isNotEmpty;
    bool isEmpty = renderingActivities.isEmpty;
    bool isHaveMore = renderingActivities.length > 3;
    return Column(
      children: [
        // const SizedBox(height: 16.0),

        if (!loading && (isFinishedAll || isEmpty) && !hasReminder)
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  isFinishedAll
                      ? R.drawable.im_activity_complete
                      : R.drawable.im_activity_empty,
                  width: 168.0,
                  height: 168.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    (isFinishedAll ? "complete_activity" : "empty_activity")
                        .tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      height: 20.0 / 14.0,
                      color: R.color.primaryGreyColor,
                    ),
                  ),
                ),

                const SizedBox(height: 24.0),

                // button set goal
                Center(child: _buttonSetNewGoal()),

                const SizedBox(height: 16.0),
              ],
            ),
          ),

        if (loading && isEmpty) const SizedBox(height: 64.0),

        if (!isEmpty && !isHaveMore)
          for (var activity in renderingActivities)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityItem(activity),
            ),
        if (!isEmpty && isHaveMore && !expanded)
          for (var activity in renderingActivities.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityItem(activity),
            ),
        if (!isEmpty && isHaveMore && expanded)
          for (var activity in renderingActivities)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityItem(activity),
            ),

        // button more
        // Builder(builder: (context) {
        //   if (isEmpty || !isHaveMore) return const SizedBox.shrink();
        //   return Padding(
        //     padding: const EdgeInsets.only(top: 4.0),
        //     child: InkWell(
        //       onTap: expanded ? onCollapse : onExpand,
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Text(
        //             expanded ? "Thu gọn" : "Mở rộng",
        //             style: TextStyle(
        //               fontSize: 14.0,
        //               color: R.color.primaryGreyColor,
        //               height: 20.0 / 14.0,
        //             ),
        //           ),
        //           const SizedBox(width: 6.0),
        //           Icon(
        //             expanded
        //                 ? Icons.keyboard_arrow_up
        //                 : Icons.keyboard_arrow_down,
        //             color: R.color.primaryGreyColor,
        //             size: 20.0,
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // }),
      ],
    );
  }

  Widget _buildActivityItem(HomeActivityData activity) {
    return InkWell(
      onTap: () => onActivityTap(activity),
      borderRadius: BorderRadius.circular(12.0),
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
            // Icon
            Container(
              width: 58,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    activity.icon,
                    width: 24.0,
                    height: 24.0,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    Utils.getActivityIconDescription(activity.type),
                    style: TextStyle(
                      fontSize: 10,
                      color: Utils.getActivityIconTextColor(activity.type),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0),

            // Content
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activity.type == ScheduleType.lesson ||
                              activity.type == ScheduleType.survey
                          ? (activity.description ?? '')
                          : activity.title,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: R.color.black,
                        height:
                            activity.description != null ? 18.0 / 15.0 : 1.2,
                      ),
                      maxLines: 2,
                    ),
                    if ((activity.description ?? '').isNotEmpty)
                      const SizedBox(height: 4),
                    if (activity.description != null &&
                        getSubtitle(activity).isNotEmpty)
                      Text(
                        getSubtitle(activity),
                        style: TextStyle(
                          fontSize: 13.0,
                          color: R.color.color0xff666666,
                          height: 16.0 / 13.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: R.color.burntSienna,
              size: 24.0,
            )
          ],
        ),
      ),
    );
  }

  String getSubtitle(HomeActivityData activity) {
    final type = activity.type;
    if (type == ScheduleType.lesson) {
      return activity.smartGoal.lessonData?.lessonModule?.name ?? '';
    }

    if (type == ScheduleType.survey) {
      return activity.title.isEmpty ? type.title : activity.title;
    }

    return activity.description ?? '';
  }

  Widget _buttonSetNewGoal() {
    return InkWell(
      onTap: onAddActivity,
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
              "Thiết lập mục tiêu",
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
    );
  }
}

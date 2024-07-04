import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

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
  });

  final bool loading;

  final List<HomeActivityData> activities;
  final bool expanded;

  final VoidCallback onViewMore;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final VoidCallback onAddActivity;
  final OnActivityTap onActivityTap;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = max(1.0, MediaQuery.of(context).textScaleFactor);
    List<HomeActivityData> renderingActivities =
        activities.where((e) => e.smartGoal.state != 1).toList();
    bool isFinishedAll = renderingActivities.isEmpty && activities.isNotEmpty;
    bool isEmpty = renderingActivities.isEmpty;
    bool isHaveMore = renderingActivities.length > 3;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hoạt động hôm nay",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: R.color.color0xff27272A,
                  ),
                ),
                SizedBox(
                  height: 24.0,
                  child: loading
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: SizedBox(
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                              width: 16.0,
                              height: 16.0,
                            ),
                          ),
                        )
                      : TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              color: R.color.greenGradientBottom,
                            ),
                          ),
                          onPressed: onViewMore,
                          child: Text("Xem thêm"),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 16.0),

            if (isFinishedAll)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      R.drawable.im_complete_activity,
                      width: 168.0,
                      height: 168.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "complete_activity".tr(),
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
              )
            else if (isEmpty)
              SizedBox(
                height: loading ? 64.0 : 164.0,
                child: loading
                    ? null
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "empty_activity".tr(),
                              style: TextStyle(
                                fontSize: 14.0,
                                height: 20.0 / 14.0,
                                color: R.color.primaryGreyColor,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24.0),

                            // button set goal
                            Center(child: _buttonSetNewGoal()),
                          ],
                        ),
                      ),
              ),

            if (!isEmpty && !isHaveMore)
              for (var activity in renderingActivities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity, textScaleFactor),
                ),
            if (!isEmpty && isHaveMore && !expanded)
              for (var activity in renderingActivities.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity, textScaleFactor),
                ),
            if (!isEmpty && isHaveMore && expanded)
              for (var activity in renderingActivities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity, textScaleFactor),
                ),

            // button more
            Builder(builder: (context) {
              if (isEmpty || !isHaveMore) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: InkWell(
                  onTap: expanded ? onCollapse : onExpand,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        expanded ? "Thu gọn" : "Mở rộng",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: R.color.primaryGreyColor,
                          height: 20.0 / 14.0,
                        ),
                      ),
                      const SizedBox(width: 6.0),
                      Icon(
                        expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: R.color.primaryGreyColor,
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(HomeActivityData activity, double textScaleFactor) {
    return InkWell(
      onTap: () => onActivityTap(activity),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 64.0 * textScaleFactor,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Color(0xFFE1FAF8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Image.asset(
              activity.icon,
              width: 32.0,
              height: 32.0,
            ),

            const SizedBox(width: 12.0),

            // Content
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: R.color.greenGradientBottom,
                        height: activity.description != null ? 24.0 / 15.0 : 1.0,
                      ),
                      maxLines: 1,
                    ),
                    if (activity.description != null)
                      Text(
                        activity.description!,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: R.color.greenGradientBottom,
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
              color: R.color.greenGradientBottom,
              size: 24.0,
            )
          ],
        ),
      ),
    );
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

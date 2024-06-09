import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import '../schema/measurement_schema.dart';

class HomeActivity extends StatelessWidget {
  const HomeActivity({
    super.key,
    required this.activities,
    required this.onViewMore,
    required this.onViewLess,
    this.expanded = false,
  });

  final List<HomeActivityData> activities;
  final bool expanded;

  final VoidCallback onViewMore;
  final VoidCallback onViewLess;

  @override
  Widget build(BuildContext context) {
    bool isEmpty = activities.isEmpty;
    bool isHaveMore = activities.length > 3;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: Container(
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
                  "Hoạt động hôm nay",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: R.color.color0xff27272A,
                  ),
                ),
                TextButton(
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
              ],
            ),

            const SizedBox(height: 16.0),

            if (isEmpty)
              SizedBox(
                height: 100.0,
                child: Center(
                  child: Text(
                    "Không có hoạt động nào",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: R.color.grey,
                      height: 20.0 / 14.0,
                    ),
                  ),
                ),
              ),

            if (!isEmpty && !isHaveMore)
              for (var activity in activities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity),
                ),
            if (!isEmpty && isHaveMore && !expanded)
              for (var activity in activities.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity),
                ),
            if (!isEmpty && isHaveMore && expanded)
              for (var activity in activities)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(activity),
                ),

            // button more
            Builder(builder: (context) {
              if (isEmpty || !isHaveMore) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: InkWell(
                  onTap: expanded ? onViewLess : onViewMore,
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

  Widget _buildActivityItem(HomeActivityData activity) {
    return Container(
      height: 64.0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: R.color.greenGradientBottom,
                    height: 24.0 / 15.0,
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

          // Arrow
          Icon(
            Icons.chevron_right,
            color: R.color.greenGradientBottom,
            size: 24.0,
          )
        ],
      ),
    );
  }
}

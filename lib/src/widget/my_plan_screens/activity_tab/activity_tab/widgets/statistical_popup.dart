import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';

enum StatisticalAction {
  my_progress,
  my_report,
  chatting,
}

class StatisticalPopup extends StatelessWidget {
  const StatisticalPopup({Key? key, required this.hasRoadmapUser, required this.hasNewReports}) : super(key: key);
  final bool hasRoadmapUser;
  final bool hasNewReports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        if (hasRoadmapUser)
          _buildSingleButton(
            title: R.string.my_progress,
            icon: R.drawable.ic_activity_process,
            onTap: () {
              NavigationUtil.pop(context, result: StatisticalAction.my_progress);
            },
          ),
        _buildSingleButton(
          title: 'Báo cáo của tôi',
          icon: R.drawable.ic_report,
          hasNewReports: hasNewReports,
          onTap: () {
            NavigationUtil.pop(context, result: StatisticalAction.my_report);
          },
        ),
        _buildSingleButton(
          title: R.string.expert_comment,
          icon: R.drawable.ic_chat,
          onTap: () {
            NavigationUtil.pop(context, result: StatisticalAction.chatting);
          },
        ),
        _buildSingleButton(
          onTap: () {
            NavigationUtil.pop(context);
          },
        ),
        const Expanded(flex: 2, child: SizedBox()),
      ],
    );
  }

  Widget _buildSingleButton({
    String? title,
    String? icon,
    required VoidCallback onTap,
    bool hasNewReports = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (title?.isNotEmpty == true)
            Text(
              title ?? '',
              style: TextStyle(
                color: R.color.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          Container(
            margin: const EdgeInsets.only(left: 14, bottom: 12, right: 16),
            alignment: Alignment.center,
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: R.color.white,
              gradient: title == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [R.color.greenGradientTop, R.color.greenGradientBottom])
                  : null,
              shape: BoxShape.circle,
            ),
            child: title == null
                ? Icon(
                    Icons.close,
                    color: R.color.white,
                    size: 32,
                  )
                : Stack(
                  children: [
                    Image.asset(
                        icon ?? '',
                        width: 32,
                        height: 32,
                    ),
                    Visibility(
                      visible: hasNewReports,
                      child: Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: R.color.greenGradientTop)),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}
